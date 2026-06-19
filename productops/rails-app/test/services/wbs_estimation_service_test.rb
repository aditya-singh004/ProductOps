require "test_helper"

class WbsEstimationServiceTest < ActiveSupport::TestCase
  test "summarizes estimates actuals blockers and completion" do
    _org, project = demo_project
    user = demo_user("developer")
    requirement = demo_requirement(project, user)
    requirement.wbs_items.create!(title: "Done", category: "backend", estimated_hours: 4, actual_hours: 5, complexity: "low", risk_level: "low", status: "done")
    requirement.wbs_items.create!(title: "Blocked", category: "qa", estimated_hours: 6, actual_hours: 1, complexity: "medium", risk_level: "medium", status: "blocked", blocked_reason: "Waiting")

    summary = WbsEstimationService.new(requirement.wbs_items).summary

    assert_equal 10.0, summary[:total_estimate]
    assert_equal 6.0, summary[:total_actual]
    assert_equal 1, summary[:blocked_tasks]
    assert_equal 50, summary[:completion_percentage]
  end
end
