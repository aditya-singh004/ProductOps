module Api
  class ProjectsController < ApplicationController
    def index
      projects = current_user.admin? ? Project.active : Project.active.joins(:memberships).where(memberships: { user_id: current_user.id })
      render json: projects.order(:name).select(:id, :name, :key)
    end
  end
end
