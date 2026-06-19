class AuthorizationService
  PERMISSIONS = {
    "admin" => %i[manage_users manage_projects manage_requirements manage_sprints manage_releases approve_production import_logs view_audit update_tasks update_checklist view],
    "project_manager" => %i[manage_requirements manage_sprints manage_releases update_tasks update_checklist view],
    "developer" => %i[update_tasks add_comments link_commits resolve_gaps view],
    "qa" => %i[update_tasks update_checklist block_release view],
    "client_viewer" => %i[view]
  }.freeze

  def initialize(user, project = nil)
    @user = user
    @project = project
  end

  def allowed?(permission)
    return false unless @user
    PERMISSIONS.fetch(role, []).include?(permission)
  end

  def authorize!(permission)
    return true if allowed?(permission)
    raise NotAuthorizedError, "You are not allowed to perform this action."
  end

  def role
    @project ? @user.project_role(@project) : @user.role
  end

  class NotAuthorizedError < StandardError; end
end
