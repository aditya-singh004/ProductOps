require "test_helper"

class DependencyServicesTest < ActiveSupport::TestCase
  setup do
    _org, @project = demo_project
    @user = demo_user("developer")
    @requirement = demo_requirement(@project, @user)
    @sprint = @project.sprints.create!(name: "Sprint", goal: "Test graph", start_date: Date.current, end_date: Date.current + 7.days, status: "active")
    @a = task("A", 2, "done")
    @b = task("B", 5, "in_progress")
    @c = task("C", 8, "blocked", "External blocker")
    TaskDependency.create!(predecessor_task: @a, successor_task: @b)
    TaskDependency.create!(predecessor_task: @b, successor_task: @c)
  end

  test "detects cycle from candidate dependency" do
    candidate = TaskDependency.new(predecessor_task: @c, successor_task: @a)

    assert CycleDetectionService.new([@a, @b, @c], extra_dependency: candidate).cycle?
  end

  test "sorts tasks topologically" do
    order = TopologicalSortService.new([@a, @b, @c]).order

    assert_equal [@a.id, @b.id, @c.id], order.map(&:id)
  end

  test "calculates critical path" do
    path = CriticalPathService.new([@a, @b, @c]).path

    assert_equal [@a.id, @b.id, @c.id], path.map(&:id)
  end

  test "propagates blocker risk downstream" do
    TaskDependency.delete_all
    TaskDependency.create!(predecessor_task: @c, successor_task: @b)

    at_risk = BlockerPropagationService.new([@a, @b, @c]).at_risk_tasks

    assert_equal [@b.id], at_risk.map(&:id)
  end

  private

  def task(title, estimate, status, blocked_reason = nil)
    @requirement.wbs_items.create!(sprint: @sprint, title: title, category: "backend", estimated_hours: estimate, actual_hours: 0, complexity: "medium", risk_level: "medium", status: status, blocked_reason: blocked_reason)
  end
end
