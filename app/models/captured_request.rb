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
end
