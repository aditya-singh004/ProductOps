class SprintsController < ApplicationController
  def index
    @project = Project.active.find(params[:project_id])
    authorize! :view, @project
    @sprints = @project.sprints.order(start_date: :desc)
  end

  def show
    @project = Project.active.find(params[:project_id])
    @sprint = @project.sprints.find(params[:id])
    authorize! :view, @project
    @tasks = @sprint.wbs_items.includes(:requirement, :owner)
    @summary = @sprint.summary
    @critical_path = CriticalPathService.new(@tasks.to_a).path
    @execution_order = TopologicalSortService.new(@tasks.to_a).order
    @at_risk_tasks = BlockerPropagationService.new(@tasks.to_a).at_risk_tasks
  end
end
