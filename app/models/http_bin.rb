class HttpBin < ApplicationRecord
  belongs_to :user
  has_many :captured_requests, dependent: :destroy
  has_many :mock_rules, dependent: :destroy

  validates :name, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  scope :for_user, ->(user) { where(user: user) }

  def ingest_url
    "/b/#{token}"
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(16)
  end
end
