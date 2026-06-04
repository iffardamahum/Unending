class CapturedRequest < ApplicationRecord
  belongs_to :http_bin
  belongs_to :matched_rule, class_name: "MockRule", optional: true

  HTTP_METHODS = %w[GET POST PUT PATCH DELETE HEAD OPTIONS].freeze

  validates :request_id, presence: true, uniqueness: true
  validates :http_method, inclusion: { in: HTTP_METHODS }
  validates :path, presence: true

  before_validation :generate_request_id, on: :create

  scope :recent,       -> { order(created_at: :desc) }
  scope :matched,      -> { where(matched_mock: true) }
  scope :unmatched,    -> { where(matched_mock: false) }
  scope :by_method,    ->(m) { where(http_method: m.upcase) }

  def self.stats_for(http_bin)
    scope = where(http_bin: http_bin)
    {
      total:     scope.count,
      matched:   scope.matched.count,
      unmatched: scope.unmatched.count
    }
  end

  private

  def generate_request_id
    self.request_id ||= SecureRandom.uuid
  end


  def self.ransackable_associations(auth_object = nil)
  [ "http_bin", "matched_rule" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "body", "content_type", "created_at", "duration_ms", "headers", "http_bin_id", "http_method", "id", "id_value", "matched_mock", "matched_rule_id", "path", "query_params", "remote_ip", "request_id", "response_body", "response_headers", "response_status", "updated_at" ]
  end
end
