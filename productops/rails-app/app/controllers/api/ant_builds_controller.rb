module Api
  class AntBuildsController < ApplicationController
    def import
      project = Project.active.find(params[:project_id])
      authorize! :import_logs, project
      log_output = params[:build_log]&.read || params[:log_output]
      build = project.build_runs.create!(AntBuildLogParserService.new(log_output).parse)
      ActivityLogger.log(user: current_user, project: project, entity: build, action: "Ant build log imported")
      render json: build, status: :created
    end
  end
end
