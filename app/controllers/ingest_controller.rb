# Captures ANY HTTP request sent to /b/:token/*
# This is the core "ingest" endpoint of the platform.
class IngestController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :find_bin

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
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Bin not found" }, status: :not_found
  end

  def find_matching_rule
    @bin.mock_rules
        .active
        .ordered
        .find { |rule| rule.matches?(request.method, request.path) }
  end

  def extract_headers
    request.headers.env.select { |k, _| k.start_with?("HTTP_") }
                        .transform_keys { |k| k.sub("HTTP_", "").split("_").map(&:capitalize).join("-") }
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
