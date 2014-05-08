class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  http_basic_authenticate_with name: "tahi", password: "tahi3000", if: -> { %w(production staging).include? Rails.env }

  before_filter :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordInvalid, with: :render_errors

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).concat %i(first_name last_name email username)
  end

  private

  def verify_admin!
    return if current_user.admin?

    if request.xhr? # Ember request
      head :forbidden
    else
      redirect_to(root_path, alert: "Permission denied")
    end
  end

  def render_errors(e)
    render status: 422, json: {errors: e.record.errors}
  end

  # customize devise signout path
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
