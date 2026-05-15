class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :http_bins, dependent: :destroy
  has_many :captured_requests, through: :http_bins
  has_many :mock_rules, through: :http_bins

   def self.ransackable_attributes(auth_object = nil)
    ["confirmation_sent_at", "confirmation_token", "confirmed_at", "created_at", "current_sign_in_at", "current_sign_in_ip", "email", "encrypted_password", "failed_attempts", "id", "id_value", "last_sign_in_at", "last_sign_in_ip", "locked_at", "remember_created_at", "reset_password_sent_at", "reset_password_token", "sign_in_count", "unconfirmed_email", "unlock_token", "updated_at"]
  end
  
end


