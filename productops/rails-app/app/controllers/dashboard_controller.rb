class DashboardController < ApplicationController
  def index
    visible = current_user.admin? ? Project.active : Project.active.joins(:memberships).where(memberships: { user_id: current_user.id })
    @projects = visible.includes(:requirements, :sprints, :releases).limit(10)
    @latest_build = BuildRun.order(executed_at: :desc).first
    @recent_activity = ActivityLog.includes(:user, :project).order(created_at: :desc).limit(12)
    @risk_reports = RiskReport.order(created_at: :desc).limit(5)
  end
end
