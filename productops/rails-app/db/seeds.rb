ActivityLog.delete_all
SvnCommit.delete_all
BuildRun.delete_all
RiskReport.delete_all
Deployment.delete_all
ReleaseChecklist.delete_all
Release.delete_all
TaskDependency.delete_all
WbsItem.delete_all
Sprint.delete_all
DecisionNote.delete_all
ClarificationQuestion.delete_all
RequirementGap.delete_all
Requirement.delete_all
Membership.delete_all
Project.delete_all
Organization.delete_all
User.delete_all

org = Organization.create!(name: "ProductOps Demo Organization")

users = {
  admin: User.create!(name: "Aarav Admin", email: "admin@productops.dev", password: "password123", role: "admin"),
  pm: User.create!(name: "Priya PM", email: "pm@productops.dev", password: "password123", role: "project_manager"),
  dev: User.create!(name: "Dev Mehta", email: "dev@productops.dev", password: "password123", role: "developer"),
  qa: User.create!(name: "Qiana QA", email: "qa@productops.dev", password: "password123", role: "qa"),
  client: User.create!(name: "Client Viewer", email: "client@productops.dev", password: "password123", role: "client_viewer")
}

payments = org.projects.create!(name: "Payments Modernization Platform", key: "PAY", description: "Modernize refunds, settlement, and deployment controls for a legacy payments stack.")
inventory = org.projects.create!(name: "Inventory Reliability Portal", key: "INV", description: "Operational visibility for warehouse stock movements and release readiness.")

[payments, inventory].each do |project|
  users.each_value { |user| Membership.create!(organization: org, project: project, user: user, role: user.role) }
end

refund = payments.requirements.create!(
  title: "Add refund workflow for failed transactions",
  description: "Support controlled refunds for failed card and UPI transactions with approval, audit history, and rollback guidance.",
  business_value: "Reduces manual operations effort and improves customer support turnaround.",
  priority: "critical",
  status: "ready_for_estimation",
  created_by: users[:pm],
  assigned_owner: users[:dev]
)
settlement = payments.requirements.create!(title: "Expose settlement reconciliation dashboard", description: "Show unsettled payment batches and exception causes.", business_value: "Improves finance visibility.", priority: "high", status: "ready_for_estimation", created_by: users[:pm], assigned_owner: users[:dev])
audit = payments.requirements.create!(title: "Capture release approval audit trail", description: "Record production approvals, override reasons, and checklist state.", business_value: "Supports compliance reviews.", priority: "high", status: "ready_for_estimation", created_by: users[:pm], assigned_owner: users[:qa])
inventory_req = inventory.requirements.create!(title: "Detect negative inventory drift", description: "Alert when stock events create impossible negative counts.", business_value: "Prevents shipping errors.", priority: "medium", status: "draft", created_by: users[:pm], assigned_owner: users[:dev])
inventory_sync = inventory.requirements.create!(title: "Nightly warehouse sync checklist", description: "Track sync jobs and failed rows for nightly operations.", business_value: "Reduces morning incident triage.", priority: "medium", status: "needs_clarification", created_by: users[:pm], assigned_owner: users[:qa])

refund.requirement_gaps.create!(title: "Gateway reversal SLA missing", description: "Need expected reversal window for each provider.", severity: "high", status: "open", assigned_to: users[:pm])
refund.clarification_questions.create!(question: "Should partial refunds be included in phase one?", answer: "No, phase one is full refunds only.", status: "answered", asked_by: users[:dev], answered_by: users[:pm])
refund.decision_notes.create!(title: "Refund approval threshold", decision: "Refunds above 5000 require PM approval.", rationale: "Limits risk during initial rollout.", decided_by: users[:pm])
payments.meeting_notes.create!(title: "Refund kickoff", attendees: "PM, backend, QA, client ops", notes: "Reviewed workflow and rollback expectations.", action_items: "PM to confirm SLA. QA to prepare regression matrix.", meeting_date: Date.current - 8.days)

sprint1 = payments.sprints.create!(name: "Sprint 24.1 Refund Foundation", goal: "Build refund workflow foundation and release guardrails.", start_date: Date.current - 7.days, end_date: Date.current + 7.days, status: "active")
sprint2 = payments.sprints.create!(name: "Sprint 24.2 Settlement Observability", goal: "Improve settlement dashboards and risk controls.", start_date: Date.current + 8.days, end_date: Date.current + 22.days, status: "planning")

tasks = []
[
  ["Create refund database migration", "database", 6, 7, "high", "medium", "done", Date.current - 2.days],
  ["Implement refund API endpoint", "backend", 12, 14, "high", "high", "in_progress", Date.current + 2.days],
  ["Add validation for transaction state", "backend", 5, 2, "medium", "medium", "todo", Date.current + 3.days],
  ["Build refund approval screen", "frontend", 8, 0, "medium", "medium", "todo", Date.current + 5.days],
  ["Add QA regression test cases", "qa", 7, 1, "medium", "medium", "blocked", Date.current + 4.days],
  ["Prepare rollback plan", "rollback", 4, 0, "low", "low", "todo", Date.current + 6.days],
  ["Verify staging deployment", "deployment", 3, 0, "medium", "medium", "backlog", Date.current + 7.days]
].each_with_index do |(title, category, estimate, actual, complexity, risk, status, due), index|
  tasks << refund.wbs_items.create!(
    sprint: sprint1,
    owner: index.even? ? users[:dev] : users[:qa],
    task_key: "PO-#{101 + index}",
    title: title,
    description: "Delivery task for #{refund.title}.",
    category: category,
    estimated_hours: estimate,
    actual_hours: actual,
    complexity: complexity,
    risk_level: risk,
    status: status,
    due_date: due,
    blocked_reason: status == "blocked" ? "Awaiting confirmed gateway sandbox credentials." : nil
  )
end

[
  ["Create settlement batch query", settlement, sprint2, "backend", 8],
  ["Design exception filters", settlement, sprint2, "frontend", 5],
  ["Add release approval migration", audit, sprint1, "database", 4],
  ["Implement audit log viewer", audit, sprint1, "frontend", 6],
  ["Write production approval tests", audit, sprint1, "qa", 5],
  ["Negative stock alert query", inventory_req, nil, "backend", 6],
  ["Warehouse sync build parser", inventory_sync, nil, "backend", 5],
  ["Document rollback checklist", audit, sprint1, "documentation", 3]
].each_with_index do |(title, requirement, sprint, category, estimate), index|
  tasks << requirement.wbs_items.create!(sprint: sprint, owner: users[:dev], task_key: "PO-#{201 + index}", title: title, description: "Planned work item.", category: category, estimated_hours: estimate, actual_hours: index, complexity: "medium", risk_level: "medium", status: sprint ? "todo" : "backlog", due_date: Date.current + 10.days)
end

TaskDependency.create!(predecessor_task: tasks[0], successor_task: tasks[1], dependency_type: "required_before")
TaskDependency.create!(predecessor_task: tasks[1], successor_task: tasks[3], dependency_type: "blocks")
TaskDependency.create!(predecessor_task: tasks[1], successor_task: tasks[4], dependency_type: "blocks")
TaskDependency.create!(predecessor_task: tasks[5], successor_task: tasks[6], dependency_type: "required_before")

release1 = payments.releases.create!(sprint: sprint1, version_number: "2026.06.1", title: "Refund Workflow Staging Release", target_date: Date.current + 9.days, environment: "staging", status: "risk_review", release_owner: users[:pm])
release1.release_checklist.update!(code_review_completed: true, unit_tests_passed: true, qa_verified: false, db_migration_reviewed: true, rollback_plan_added: true, staging_deployment_done: false, production_approval_received: false)
release2 = payments.releases.create!(sprint: sprint2, version_number: "2026.07.1", title: "Settlement Dashboard Release", target_date: Date.current + 25.days, environment: "production", status: "draft", release_owner: users[:pm])

RiskReport.create!(project: payments, sprint: sprint1, release: release1, risk_score: 78, risk_level: "HIGH", reasons: ["1 high-priority task is blocked", "Actual effort variance exceeds plan", "Critical path contains delayed tasks"], suggested_actions: ["Resolve gateway sandbox blocker", "Move release date or reduce scope"], payload: { seeded: true })
release1.deployments.create!(environment: "staging", status: "pending", deployed_by: users[:qa], logs: "Waiting for QA verification.")

SvnCommit.create!(project: payments, wbs_item: tasks[1], revision: "1842", author: "dmehta", committed_at: Time.current - 2.days, message: "PO-102 implement refund API controller", changed_paths: [{ path: "/trunk/refunds/api.rb", action: "M" }], task_key: "PO-102", imported_at: Time.current)
SvnCommit.create!(project: payments, wbs_item: tasks[0], revision: "1840", author: "dmehta", committed_at: Time.current - 4.days, message: "PO-101 create refund tables", changed_paths: [{ path: "/trunk/db/refunds.sql", action: "A" }], task_key: "PO-101", imported_at: Time.current)

BuildRun.create!(project: payments, build_tool: "ant", status: "success", duration_seconds: 21, failed_test_count: 0, log_output: "compile:\ntest:\nBUILD SUCCESSFUL\nTotal time: 21 seconds", executed_at: Time.current - 1.day)
BuildRun.create!(project: payments, build_tool: "ant", status: "failed", duration_seconds: 17, failed_test_count: 2, log_output: "test:\nFAILED RefundWorkflowTest\nBUILD FAILED\nTotal time: 17 seconds", executed_at: Time.current - 3.hours)

[refund, settlement, audit].each do |requirement|
  ActivityLogger.log(user: users[:pm], project: requirement.project, entity: requirement, action: "requirement created")
end
tasks.first(6).each do |task|
  ActivityLogger.log(user: users[:dev], project: task.requirement.project, entity: task, action: "WBS item created")
end
ActivityLogger.log(user: users[:pm], project: payments, entity: release1, action: "risk calculated", metadata: { score: 78, level: "HIGH" })

puts "Seeded ProductOps demo data."
puts "Demo login: admin@productops.dev / password123"
