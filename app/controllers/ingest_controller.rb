# Captures ANY HTTP request sent to /b/:token/*
# This is the core "ingest" endpoint of the platform.
class IngestController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :find_bin
  before_action :check_rate_limit

  def capture
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    rule = find_matching_rule
    duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).round(2)

    req = @bin.captured_requests.create!(
      http_method:     request.method,
      path:            request.path,
      headers:         extract_headers,
      query_params:    request.query_parameters.to_h,
      body:            read_body,
      content_type:    request.content_type,
      remote_ip:       request.remote_ip,
      response_status: rule&.response_status || 200,
      response_headers: rule&.response_headers || {},
      response_body:   rule&.response_body,
      duration_ms:     duration,
      matched_mock:    rule.present?,
      matched_rule:    rule
    )

    # Broadcast via Turbo Streams for real-time UI updates
    Turbo::StreamsChannel.broadcast_prepend_to(
      "bin_#{@bin.token}",
      target:  "captured_requests",
      partial: "captured_requests/row",
      locals:  { captured_request: req }
    )

    simulate_delay(rule)
    render_mock_response(req, rule)
  end

  private

  def find_bin
    @bin = HttpBin.find_by!(token: params[:token])
    if @bin.expires_at.present? && @bin.expires_at < Time.current
      render json: { error: "Bin has expired" }, status: :gone
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Bin not found" }, status: :not_found
  end

  def check_rate_limit
    key = "rate_limit:#{@bin.token}"
    count = REDIS.incr(key)
    REDIS.expire(key, 60) if count == 1 # 60 = 1 minute expiration for the key

    if count > 5  # count how many times you want to allow per minute
    render json: { error: "Rate limit exceeded. Try again in a minute" },
           status: :too_many_requests
    end
  end

  def find_matching_rule
    @bin.mock_rules
        .active
        .ordered
        .find { |rule| rule.matches?(request.method, params[:path]) }
  end


  SENSITIVE_HEADERS = %w[authorization cookie set-cookie x-api-key x-auth-token].freeze

  def extract_headers
   request.headers.env
    .select { |k, _| k.start_with?("HTTP_") || k.in?(%w[CONTENT_TYPE CONTENT_LENGTH]) }
    .each_with_object({}) do |(key, value), hash|
      clean_key = key.sub(/^HTTP_/, "").split("_").map(&:capitalize).join("-")
      hash[clean_key] = SENSITIVE_HEADERS.include?(clean_key.downcase) ? mask_header(value) : value
    end
  end

  def mask_header(value)
    return value if value.nil?
    "[MASKED]"
  end

  def read_body
    request.body.rewind
    request.body.read
  end

  def simulate_delay(rule)
    sleep(rule.delay_ms / 1000.0) if rule&.delay_ms.to_i > 0
  end

  def render_mock_response(req, rule)
    if rule
      headers = rule.response_headers || {}
      headers.each { |k, v| response.headers[k] = v }
      render plain: rule.response_body.to_s,
             status: rule.response_status,
             content_type: rule.content_type || "application/json"
    else
      render json: {
        request_id: req.request_id,
        message:    "Request captured. No matching mock rule found.",
        captured_at: req.created_at
      }, status: 200
    end
  end
end
