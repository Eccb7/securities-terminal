class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Devise authentication
  before_action :authenticate_user!
  before_action :check_2fa_requirement

  # Pundit authorization
  include Pundit::Authorization
  after_action :verify_authorized, except: :index, unless: :skip_authorization?
  after_action :verify_policy_scoped, only: :index, unless: :skip_authorization?

  # Pundit error handling
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Set current organization
  before_action :set_current_organization

  # Audit logging
  after_action :log_user_activity, unless: :devise_controller?

  helper_method :current_organization

  private

  def current_organization
    @current_organization ||= current_user&.organization
  end

  def set_current_organization
    return unless current_user
    @current_organization = current_user.organization
  end

  def check_2fa_requirement
    return unless current_user
    return if devise_controller?
    return if current_user.otp_secret.blank?

    # Check if 2FA is verified in session
    unless session[:otp_verified]
      redirect_to verify_2fa_path, alert: "Please verify your 2FA code"
    end
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def skip_authorization?
    devise_controller? || controller_name == "home"
  end

  def log_user_activity
    return unless current_user
    return if request.method == "GET"

    AuditLog.create!(
      actor: current_user,
      action: "#{controller_name}_#{action_name}",
      payload: {
        path: request.path,
        method: request.method,
        params: filtered_params
      }
    )
  rescue => e
    Rails.logger.error "Failed to log user activity: #{e.message}"
  end

  def filtered_params
    params.to_unsafe_h.except("controller", "action", "authenticity_token", "password", "password_confirmation")
  end
end
