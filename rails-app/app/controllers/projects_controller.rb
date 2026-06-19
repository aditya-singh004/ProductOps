class ProjectsController < ApplicationController
  def index
    @projects = visible_projects.includes(:organization).order(:name)
  end

  def show
    @project = visible_projects.find(params[:id])
    authorize! :view, @project
    @requirements = @project.requirements.active.order(created_at: :desc)
    @sprints = @project.sprints.order(start_date: :desc)
    @releases = @project.releases.order(target_date: :desc)
    @commits = @project.svn_commits.order(committed_at: :desc).limit(8)
    @builds = @project.build_runs.order(executed_at: :desc).limit(5)
  end

  def new
    authorize! :manage_projects
    @project = Project.new
  end

  def create
    authorize! :manage_projects
    @project = Project.new(project_params)
    if @project.save
      ActivityLogger.log(user: current_user, entity: @project, action: "project created")
      redirect_to @project, notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def visible_projects
    return Project.active if current_user.admin?
    Project.active.joins(:memberships).where(memberships: { user_id: current_user.id })
  end

  def project_params
    params.require(:project).permit(:organization_id, :name, :description, :key)
  end
end
