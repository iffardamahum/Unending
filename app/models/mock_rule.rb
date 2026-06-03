class MockRule < ApplicationRecord
  belongs_to :http_bin
  attr_accessor :ttl

  HTTP_METHODS = %w[GET POST PUT PATCH DELETE HEAD OPTIONS ANY].freeze

  attribute :rate_limit_type, :string, default: "ip"

  before_save :set_expiration

  validates :name, presence: true
  validates :http_bin, presence: true
  validates :http_method, inclusion: { in: HTTP_METHODS }
  validates :path_pattern, presence: true
  validates :response_status, inclusion: { in: 100..599 }
  validates :priority, numericality: { greater_than_or_equal_to: 0 }
  validates :delay_ms, numericality: { greater_than_or_equal_to: 0 }
  validates :rate_limit_count, numericality: { greater_than_or_equal_to: 1, allow_nil: true }
  validates :rate_limit_period, inclusion: { in: %w[minute hour day], allow_nil: true }

  scope :ordered, -> { order(priority: :desc) }
  scope :active,  -> { where(enabled: true).where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }

  def matches?(method, path)
    method_ok = self.http_method == "ANY" || self.http_method.upcase == method.upcase
    return false unless method_ok
    clean_db_path  = self.path_pattern.to_s.gsub(%r{\A/|/\z}, "")
    clean_req_path = path.to_s.gsub(%r{\A/|/\z}, "")
    clean_db_path == clean_req_path
  end

  def rate_limit_enabled?
    rate_limit_count.present? && rate_limit_period.present?
  end

  def self.ransackable_associations(auth_object = nil)
    [ "http_bin" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "content_type", "created_at", "delay_ms", "description", "enabled",
     "http_bin_id", "http_method", "id", "id_value", "name", "path_pattern",
     "priority", "response_body", "response_headers", "response_status",
     "updated_at", "use_regex", "rate_limit_period", "rate_limit_type", "expires_at" ]
  end

  private

  def set_expiration
    if ttl.present? && ttl.to_i > 0
      self.expires_at = ttl.to_i.hours.from_now
    else
      self.expires_at = nil
    end
  end

  def method_matches?(method)
    http_method == "ANY" || http_method.casecmp(method).zero?
  end

  def path_matches?(path)
    if use_regex
      Regexp.new(path_pattern).match?(path)
    else
      File.fnmatch(path_pattern, path)
    end
  rescue RegexpError
    false
  end
end
