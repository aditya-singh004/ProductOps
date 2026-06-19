class RequirementsController < ApplicationController
  before_action :set_project, only: %i[index new create]
  before_action :set_requirement, only: %i[show edit update]

  def index
    authorize! :view, @project
    @requirements = @project.requirements.active.includes(:assigned_owner)
    @requirements = @requirements.where(status: params[:status]) if params[:status].present?
    @requirements = @requirements.where(priority: params[:priority]) if params[:priority].present?
    @requirements = @requirements.where(assigned_owner_id: params[:owner_id]) if params[:owner_id].present?
  end

  def show
    authorize! :view, @requirement.project
    @gap = @requirement.requirement_gaps.new
    @question = @requirement.clarification_questions.new
    @decision_note = @requirement.decision_notes.new
    @wbs_item = @requirement.wbs_items.new
    @summary = WbsEstimationService.new(@requirement.wbs_items).summary
  end

  def new
    authorize! :manage_requirements, @project
    @requirement = @project.requirements.new
  end

  def create
    authorize! :manage_requirements, @project
    @requirement = @project.requirements.new(requirement_params.merge(created_by: current_user))
    if @requirement.save
      ActivityLogger.log(user: current_user, project: @project, entity: @requirement, action: "requirement created")
      redirect_to @requirement, notice: "Requirement created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize! :manage_requirements, @requirement.project
  end

  def update
    authorize! :manage_requirements, @requirement.project
    old_status = @requirement.status
    if @requirement.update(requirement_params)
      ActivityLogger.log(user: current_user, project: @requirement.project, entity: @requirement, action: "requirement status changed", metadata: { from: old_status, to: @requirement.status }) if old_status != @requirement.status
      redirect_to @requirement, notice: "Requirement updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_project
    @project = Project.active.find(params[:project_id])
  end

  def set_requirement
    @requirement = Requirement.active.find(params[:id])
  end

  def requirement_params
    params.require(:requirement).permit(:title, :description, :business_value, :priority, :status, :assigned_owner_id)
  end
end
