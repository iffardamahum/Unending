class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :omniauthable, :confirmable,
         omniauth_providers: %i[google_oauth2 github]

  has_many :http_bins, dependent: :destroy
  has_many :captured_requests, through: :http_bins
  has_many :mock_rules, through: :http_bins

  def self.find_or_create_from_oauth(auth)
    # Kasus 1: User udah pernah login pake Google/GitHub sebelumnya
    user = find_by(provider: auth.provider, uid: auth.uid)
    if user
      user.skip_confirmation! # Jaga-jaga kalau akun lamanya belum tervalidasi
      user.save
      return user
    end

    # Kasus 2: User udah punya akun email manual, tapi baru pertama kali klik "Login pake Google"
    user = find_by(email: auth.info.email)
    if user
      user.update(provider: auth.provider, uid: auth.uid)
      user.skip_confirmation! # Langsung sah-kan akunnya biar gak minta aktivasi email
      user.save
      return user
    end

    # Kasus 3: User bener-bener baru (Belum ada di database sama sekali)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |new_user|
      new_user.email     = auth.info.email
      new_user.full_name = auth.info.full_name
      new_user.password  = Devise.friendly_token[0, 20]
      new_user.skip_confirmation! # Jalur VIP langsung aktif tanpa kirim Gmail
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "confirmation_sent_at", "confirmation_token", "confirmed_at",
      "created_at", "current_sign_in_at", "current_sign_in_ip",
      "email", "encrypted_password", "failed_attempts", "id",
      "id_value", "last_sign_in_at", "last_sign_in_ip", "locked_at",
      "remember_created_at", "reset_password_sent_at",
      "reset_password_token", "sign_in_count", "unconfirmed_email",
      "unlock_token", "updated_at" ]
  end
end
