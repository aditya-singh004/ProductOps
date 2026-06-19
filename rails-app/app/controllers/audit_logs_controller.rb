class AuditLogsController < ApplicationController
  def index
    authorize! :view_audit
    @activity_logs = ActivityLog.includes(:user, :project).order(created_at: :desc).limit(100)
  end
end
