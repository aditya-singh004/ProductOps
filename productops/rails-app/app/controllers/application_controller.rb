class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_login
  helper_method :current_user, :current_role

  rescue_from AuthorizationService::NotAuthorizedError, with: :deny_access
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def current_role(project = nil)
    return "guest" unless current_user
    project ? current_user.project_role(project) : current_user.role
  end

  def require_login
    redirect_to login_path, alert: "Please sign in." unless current_user
  end

  def authorize!(permission, project = nil)
    AuthorizationService.new(current_user, project).authorize!(permission)
  end

  def deny_access(error)
    respond_to do |format|
      format.html { redirect_to root_path, alert: error.message }
      format.json { render json: { error: error.message }, status: :forbidden }
    end
  end

  def not_found
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Record not found." }
      format.json { render json: { error: "Record not found" }, status: :not_found }
    end
  end
end
