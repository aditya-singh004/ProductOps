class ReleasesController < ApplicationController
  def index
    @project = Project.active.find(params[:project_id])
    authorize! :view, @project
    @releases = @project.releases.includes(:release_checklist).order(target_date: :desc)
  end

  def show
    @project = Project.active.find(params[:project_id])
    @release = @project.releases.find(params[:id])
    authorize! :view, @project
    @readiness = ReleaseReadinessService.new(@release)
  end

  def new
    @project = Project.active.find(params[:project_id])
    authorize! :manage_releases, @project
    @release = @project.releases.new
  end

  def create
    @project = Project.active.find(params[:project_id])
    authorize! :manage_releases, @project
    @release = @project.releases.new(release_params)
    if @release.save
      ActivityLogger.log(user: current_user, project: @project, entity: @release, action: "release created")
      redirect_to project_release_path(@project, @release), notice: "Release created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def release_params
    params.require(:release).permit(:sprint_id, :version_number, :title, :target_date, :environment, :status, :release_owner_id)
  end
end
