class RequirementGapsController < ApplicationController
  def create
    requirement = Requirement.find(params[:requirement_id])
    authorize! :manage_requirements, requirement.project
    gap = requirement.requirement_gaps.new(gap_params)
    if gap.save
      ActivityLogger.log(user: current_user, project: requirement.project, entity: gap, action: "requirement gap created")
      redirect_to requirement, notice: "Gap added."
    else
      redirect_to requirement, alert: gap.errors.full_messages.to_sentence
    end
  end

  def update
    gap = RequirementGap.find(params[:id])
    authorize! :resolve_gaps, gap.requirement.project
    attrs = gap_params
    attrs[:resolved_at] = Time.current if attrs[:status] == "resolved"
    if gap.update(attrs)
      ActivityLogger.log(user: current_user, project: gap.requirement.project, entity: gap, action: "gap resolved") if gap.status == "resolved"
      redirect_to gap.requirement, notice: "Gap updated."
    else
      redirect_to gap.requirement, alert: gap.errors.full_messages.to_sentence
    end
  end

  private

  def gap_params
    params.require(:requirement_gap).permit(:title, :description, :severity, :status, :assigned_to_id, :resolution_note)
  end
end
