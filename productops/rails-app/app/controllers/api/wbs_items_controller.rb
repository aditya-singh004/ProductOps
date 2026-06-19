module Api
  class WbsItemsController < ApplicationController
    def status
      item = WbsItem.find(params[:id])
      authorize! :update_tasks, item.requirement.project
      if item.update(status: params[:status], blocked_reason: params[:blocked_reason])
        ActivityLogger.log(user: current_user, project: item.requirement.project, entity: item, action: "task status changed", metadata: { status: item.status })
        render json: { id: item.id, status: item.status }
      else
        render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def actual_hours
      item = WbsItem.find(params[:id])
      authorize! :update_tasks, item.requirement.project
      if item.update(actual_hours: params[:actual_hours])
        render json: { id: item.id, actual_hours: item.actual_hours.to_f, summary: WbsEstimationService.new(item.requirement.wbs_items).summary }
      else
        render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def create_dependency
      item = WbsItem.find(params[:id])
      authorize! :manage_sprints, item.requirement.project
      dependency = TaskDependency.new(predecessor_task_id: params[:predecessor_task_id], successor_task: item, dependency_type: params[:dependency_type] || "blocks")
      if dependency.save
        render json: dependency, status: :created
      else
        render json: { errors: dependency.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy_dependency
      item = WbsItem.find(params[:id])
      authorize! :manage_sprints, item.requirement.project
      dependency = item.incoming_dependencies.find(params[:dependency_id])
      dependency.destroy!
      head :no_content
    end
  end
end
