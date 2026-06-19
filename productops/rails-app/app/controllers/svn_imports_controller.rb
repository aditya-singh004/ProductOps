class SvnImportsController < ApplicationController
  def new
    @projects = current_user.admin? ? Project.active.order(:name) : Project.active.joins(:memberships).where(memberships: { user_id: current_user.id }).order(:name)
  end

  def create
    project = Project.active.find(params[:project_id])
    authorize! :import_logs, project
    xml = params[:svn_log]&.read
    return redirect_to new_svn_import_path, alert: "Upload an XML log file." if xml.blank?

    summary = SvnLogParserService.new(xml).import!(project)
    ActivityLogger.log(user: current_user, project: project, entity: project, action: "SVN log imported", metadata: summary)
    redirect_to project, notice: "SVN import complete: #{summary[:imported]} new, #{summary[:duplicates]} duplicate, #{summary[:linked]} linked."
  end
end
