class HttpBin < ApplicationRecord
  belongs_to :user
  has_many :captured_requests, dependent: :destroy
  has_many :mock_rules, dependent: :destroy

  validates :name, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create
  before_create :set_expiration

  def set_expiration
    self.expires_at ||= 24.hours.from_now
    

  end

  scope :for_user, ->(user) { where(user: user) }
  scope :active,   -> { where("expires_at > ?", Time.current) }
  scope :expired,  -> { where("expires_at <= ?", Time.current) }


  def ingest_url
    "/b/#{token}"
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(16)
  end
  
  def self.ransackable_associations(auth_object = nil)
    ["captured_requests", "mock_rules", "user"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "description", "id", "id_value", "name", "token", "updated_at", "user_id", "expires_at"]
  end


end
