class BuildRunsController < ApplicationController
  def index
    @projects = current_user.admin? ? Project.active.order(:name) : Project.active.joins(:memberships).where(memberships: { user_id: current_user.id }).order(:name)
    @build_runs = BuildRun.includes(:project).order(executed_at: :desc).limit(50)
  end

  def create
    project = Project.active.find(params[:project_id])
    authorize! :import_logs, project
    log = params[:build_log]&.read || params[:log_output]
    attrs = AntBuildLogParserService.new(log).parse
    build = project.build_runs.create!(attrs)
    ActivityLogger.log(user: current_user, project: project, entity: build, action: "Ant build log imported")
    redirect_to build_runs_path, notice: "Ant build log imported as #{build.status}."
  end
end
