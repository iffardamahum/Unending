class MockRule < ApplicationRecord
  belongs_to :http_bin

  HTTP_METHODS = %w[GET POST PUT PATCH DELETE HEAD OPTIONS ANY].freeze

  validates :name, presence: true
  validates :http_bin, presence: true
  validates :http_method, inclusion: { in: HTTP_METHODS }
  validates :path_pattern, presence: true
  validates :response_status, inclusion: { in: 100..599 }
  validates :priority, numericality: { greater_than_or_equal_to: 0 }
  validates :delay_ms, numericality: { greater_than_or_equal_to: 0 }

  scope :active,    -> { where(enabled: true) }
  scope :ordered,   -> { order(priority: :desc) }

  def matches?(method, path)
    return false unless self.http_method.upcase == method.upcase
    clean_db_path = self.path_pattern.to_s.gsub(%r{\A/|/\z}, "")
    clean_req_path = path.to_s.gsub(%r{\A/|/\z}, "")

    clean_db_path == clean_req_path
  end

  def self.ransackable_associations(auth_object = nil)
    [ "http_bin" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "content_type", "created_at", "delay_ms", "description", "enabled", "http_bin_id", "http_method", "id", "id_value", "name", "path_pattern", "priority", "response_body", "response_headers", "response_status", "updated_at", "use_regex" ]
  end

  private

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
