class HttpBin < ApplicationRecord
  belongs_to :user
  has_many :captured_requests, dependent: :destroy
  has_many :mock_rules, dependent: :destroy

  validates :name, :user_id, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  scope :for_user, ->(user) { where(user: user) }

  def ingest_url
    "/b/#{token}"
  end

  private

  def generate_token
    self.token ||="mock_#{SecureRandom.urlsafe_base64(24)}"[0..31]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "captured_requests", "mock_rules", "user" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "description", "id", "id_value", "name", "token", "updated_at", "user_id" ]
  end
end
