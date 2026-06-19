require "test_helper"

class ReleaseReadinessServiceTest < ActiveSupport::TestCase
  test "requires checklist and non-high risk for production readiness" do
    _org, project = demo_project
    user = demo_user("project_manager")
    sprint = project.sprints.create!(name: "Sprint", start_date: Date.current, end_date: Date.current + 7.days, status: "active")
    release = project.releases.create!(sprint: sprint, version_number: "1.0.0", title: "Release", environment: "production", status: "risk_review", release_owner: user)
    release.release_checklist.update!(rollback_plan_added: true, staging_deployment_done: true, production_approval_received: true)
    RiskReport.create!(project: project, sprint: sprint, release: release, risk_score: 80, risk_level: "HIGH", reasons: [], suggested_actions: [])

    assert_not ReleaseReadinessService.new(release).production_ready?
    release.update!(production_override_reason: "Accepted for demo")
    assert ReleaseReadinessService.new(release).production_ready?(admin_override: true)
  end
end
