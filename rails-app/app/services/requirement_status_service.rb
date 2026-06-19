class RequirementStatusService
  def initialize(requirement)
    @requirement = requirement
  end

  def sync!
    return if @requirement.status == "released"
    next_status = @requirement.open_gaps? ? "needs_clarification" : "ready_for_estimation"
    @requirement.update_column(:status, next_status) if @requirement.status != next_status
  end
end
