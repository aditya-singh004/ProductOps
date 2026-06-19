class RiskCalculationJob < ApplicationJob
  queue_as :default

  def perform(sprint_id, release_id = nil)
    sprint = Sprint.find(sprint_id)
    release = Release.find_by(id: release_id)
    response = RiskEngineClient.new.calculate(sprint: sprint, release: release)
    RiskReport.create!(
      project: sprint.project,
      sprint: sprint,
      release: release,
      risk_score: response.fetch("riskScore"),
      risk_level: response.fetch("riskLevel"),
      reasons: response.fetch("reasons", []),
      suggested_actions: response.fetch("suggestedActions", []),
      payload: response
    )
  end
end
