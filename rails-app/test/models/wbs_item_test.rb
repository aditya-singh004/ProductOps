require "test_helper"

class WbsItemTest < ActiveSupport::TestCase
  test "blocked item requires blocked reason" do
    _org, project = demo_project
    user = demo_user("developer")
    requirement = demo_requirement(project, user)

    item = requirement.wbs_items.new(title: "Blocked task", category: "backend", estimated_hours: 3, complexity: "medium", risk_level: "medium", status: "blocked")

    assert_not item.valid?
    assert_includes item.errors[:blocked_reason], "can't be blank"
  end

  test "high complexity cannot remain low risk" do
    _org, project = demo_project
    user = demo_user("developer")
    requirement = demo_requirement(project, user)

    item = requirement.wbs_items.create!(title: "Hard task", category: "backend", estimated_hours: 3, complexity: "high", risk_level: "low", status: "todo")

    assert_equal "medium", item.risk_level
  end
end
