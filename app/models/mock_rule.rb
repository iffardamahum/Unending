class MockRule < ApplicationRecord
  belongs_to :http_bin

  HTTP_METHODS = %w[GET POST PUT PATCH DELETE HEAD OPTIONS ANY].freeze

  validates :name, presence: true
  validates :http_method, inclusion: { in: HTTP_METHODS }
  validates :path_pattern, presence: true
  validates :response_status, inclusion: { in: 100..599 }
  validates :priority, numericality: { greater_than_or_equal_to: 0 }
  validates :delay_ms, numericality: { greater_than_or_equal_to: 0 }

  scope :active,    -> { where(enabled: true) }
  scope :ordered,   -> { order(priority: :desc) }

  def matches?(method, path)
    method_matches?(method) && path_matches?(path)
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
