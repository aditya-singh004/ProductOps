module Api
  class ReleasesController < ApplicationController
    def checklist
      release = Release.find(params[:id])
      authorize! :update_checklist, release.project
      checklist = release.release_checklist
      allowed = ReleaseChecklist::STAGING_FIELDS + ReleaseChecklist::PRODUCTION_FIELDS
      attrs = params.permit(*allowed)
      if checklist.update(attrs)
        ActivityLogger.log(user: current_user, project: release.project, entity: release, action: "release checklist updated", metadata: attrs.to_h)
        render json: checklist
      else
        render json: { errors: checklist.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def approve_production
      release = Release.find(params[:id])
      authorize! :approve_production, release.project
      release.production_override_reason = params[:override_reason] if params[:override_reason].present?
      readiness = ReleaseReadinessService.new(release)
      unless readiness.production_ready?(admin_override: current_user.admin?)
        return render json: { errors: readiness.production_errors }, status: :unprocessable_entity
      end
      release.update!(status: "production_ready")
      ActivityLogger.log(user: current_user, project: release.project, entity: release, action: "production release approved", metadata: { override: release.production_override_reason.present? })
      render json: release
    end
  end
end
