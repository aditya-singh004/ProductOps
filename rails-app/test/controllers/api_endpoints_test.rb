require "test_helper"

class ApiEndpointsTest < ActionDispatch::IntegrationTest
  setup do
    @org, @project = demo_project
    @admin = demo_user("admin")
    Membership.create!(organization: @org, project: @project, user: @admin, role: "admin")
    @requirement = demo_requirement(@project, @admin)
    @task = @requirement.wbs_items.create!(title: "Task", category: "backend", estimated_hours: 3, actual_hours: 0, complexity: "medium", risk_level: "medium", status: "todo")
    post login_path, params: { email: @admin.email, password: "password123" }
  end

  test "updates task status through json endpoint" do
    patch api_wbs_item_status_path(@task), params: { status: "in_progress" }, as: :json

    assert_response :success
    assert_equal "in_progress", @task.reload.status
  end

  test "rejects invalid blocked status without reason" do
    patch api_wbs_item_status_path(@task), params: { status: "blocked" }, as: :json

    assert_response :unprocessable_entity
  end
end
