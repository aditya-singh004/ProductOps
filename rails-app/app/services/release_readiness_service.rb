class ReleaseReadinessService
  def initialize(release)
    @release = release
    @checklist = release.release_checklist
  end

  def staging_ready?
    @checklist&.staging_complete?
  end

  def production_ready?(admin_override: false)
    return false unless @checklist&.production_complete?
    risk_level = @release.latest_risk_report&.risk_level
    risk_level != "HIGH" || (admin_override && @release.production_override_reason.present?)
  end

  def staging_errors
    missing = ReleaseChecklist::STAGING_FIELDS.reject { |field| @checklist.public_send(field) }
    missing.map { |field| "#{field.to_s.humanize} must be completed" }
  end

  def production_errors
    errors = ReleaseChecklist::PRODUCTION_FIELDS.reject { |field| @checklist.public_send(field) }.map { |field| "#{field.to_s.humanize} must be completed" }
    errors << "High risk requires admin override reason" if @release.latest_risk_report&.risk_level == "HIGH" && @release.production_override_reason.blank?
    errors
  end
end
