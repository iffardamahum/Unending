class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_auth "Google"
  end

  # def github
  # handle_auth "GitHub"
  # end

  def failure
    redirect_to root_path, alert: "Authentication failed. Please try again."
  end

 private

  def handle_auth(provider_name)
    auth = request.env["omniauth.auth"]
    @user = User.find_or_create_from_oauth(auth)
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
    else
      session["devise.oauth_data"] = auth.except(:extra)
      redirect_to root_path, alert: "Could not sign in with #{provider_name}."
    end
  end
end
