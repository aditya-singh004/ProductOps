module Api
  class SvnController < ApplicationController
    def import
      project = Project.active.find(params[:project_id])
      authorize! :import_logs, project
      xml = params[:svn_log]&.read || params[:xml]
      summary = SvnLogParserService.new(xml).import!(project)
      ActivityLogger.log(user: current_user, project: project, entity: project, action: "SVN log imported", metadata: summary)
      render json: summary, status: :created
    end
  end
end
