module Api
  class SprintsController < ApplicationController
    def index
      project = Project.active.find(params[:project_id])
      authorize! :view, project
      render json: project.sprints.order(start_date: :desc)
    end

    def board
      sprint = Sprint.find(params[:id])
      authorize! :view, sprint.project
      tasks = sprint.wbs_items.includes(:requirement, :owner).map do |task|
        {
          id: task.id,
          key: task.task_key,
          title: task.title,
          status: task.status,
          priority: task.requirement.priority,
          owner: task.owner&.name,
          blocked: task.blocked?,
          overdue: task.overdue?
        }
      end
      render json: { sprint: sprint.slice(:id, :name, :status), tasks: tasks, summary: sprint.summary }
    end

    def calculate_risk
      sprint = Sprint.find(params[:id])
      authorize! :manage_releases, sprint.project
      response = RiskEngineClient.new.calculate(sprint: sprint)
      report = sprint.risk_reports.create!(
        project: sprint.project,
        risk_score: response.fetch("riskScore"),
        risk_level: response.fetch("riskLevel"),
        reasons: response.fetch("reasons", []),
        suggested_actions: response.fetch("suggestedActions", []),
        payload: response
      )
      ActivityLogger.log(user: current_user, project: sprint.project, entity: report, action: "risk calculated")
      render json: report, status: :created
    rescue RiskEngineClient::Unavailable => e
      render json: { error: "Risk engine unavailable", detail: e.message }, status: :service_unavailable
    end
  end
end
