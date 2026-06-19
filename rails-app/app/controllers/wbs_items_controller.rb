class WbsItemsController < ApplicationController
  def create
    requirement = Requirement.find(params[:requirement_id])
    authorize! :manage_sprints, requirement.project
    item = requirement.wbs_items.new(wbs_params)
    if item.save
      ActivityLogger.log(user: current_user, project: requirement.project, entity: item, action: "WBS item created")
      redirect_to requirement, notice: "WBS item added."
    else
      redirect_to requirement, alert: item.errors.full_messages.to_sentence
    end
  end

  def update
    item = WbsItem.find(params[:id])
    authorize! :update_tasks, item.requirement.project
    if item.update(wbs_params)
      ActivityLogger.log(user: current_user, project: item.requirement.project, entity: item, action: "task status changed")
      redirect_to item.requirement, notice: "WBS item updated."
    else
      redirect_to item.requirement, alert: item.errors.full_messages.to_sentence
    end
  end

  private

  def wbs_params
    params.require(:wbs_item).permit(:sprint_id, :owner_id, :title, :description, :category, :estimated_hours, :actual_hours, :complexity, :risk_level, :status, :due_date, :blocked_reason)
  end
end
