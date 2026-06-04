class ApplicationController < ActionController::Base
  include Pagy::Backend

  layout :layout_by_resource
  before_action :bypass_ngrok_warning

  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :authenticate_user!

  def authenticate_admin_user!
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied."
    end
  end

  def current_admin_user
    current_user if current_user&.admin?
  end

  helper_method :current_admin_user

  private

      def bypass_ngrok_warning
        response.headers["ngrok-skip-browser-warning"] = "true"
      end

      def layout_by_resource
        devise_controller? ? "devise" : "application"
      end
end
