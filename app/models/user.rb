class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :http_bins, dependent: :destroy
  has_many :captured_requests, through: :http_bins
  has_many :mock_rules, through: :http_bins
end
