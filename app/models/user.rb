class User < ApplicationRecord
  ROLES = %w[member admin super_admin].freeze
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :omniauthable, :confirmable,
         omniauth_providers: %i[google_oauth2 github]

  has_many :http_bins, dependent: :destroy
  has_many :captured_requests, through: :http_bins
  has_many :mock_rules, through: :http_bins

  def member?
    role == "member"
  end

  def admin?
    role == "admin" || role == "super_admin"
  end

  def super_admin?
    role == "super_admin"
  end

  def display_name
        self.email
  end


  def self.find_or_create_from_oauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid)
    if user
      user.skip_confirmation!
      user.save
      return user
    end


    user = find_by(email: auth.info.email)
    if user
      user.update(provider: auth.provider, uid: auth.uid)
      user.skip_confirmation!
      user.save
      return user
    end


    where(provider: auth.provider, uid: auth.uid).first_or_create do |new_user|
      new_user.email     = auth.info.email
      new_user.full_name = auth.info.full_name
      new_user.password  = Devise.friendly_token[0, 20]
      new_user.skip_confirmation!
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[email created_at role sign_in_count last_sign_in_at
     confirmation_sent_at confirmed_at current_sign_in_at
     current_sign_in_ip failed_attempts last_sign_in_at
     last_sign_in_ip locked_at remember_created_at
     reset_password_sent_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "captured_requests", "http_bins", "mock_rules" ]
  end
end
