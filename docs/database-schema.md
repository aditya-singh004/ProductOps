# Database Schema

## Tables

- `users`: secure password digest, email, and global role.
- `organizations`: tenant-style grouping.
- `memberships`: organization/project membership and project-level role.
- `projects`: product delivery workspaces with soft delete.
- `requirements`: requirement tracker with priority and workflow status.
- `requirement_gaps`: missing information, severity, assignment, and resolution.
- `clarification_questions`: question/answer workflow.
- `decision_notes`: product or technical decisions.
- `meeting_notes`: project meeting notes and action items.
- `sprints`: sprint planning and execution windows.
- `wbs_items`: sprint tasks with estimates, actuals, complexity, risk, owner, status, blockers, and soft delete.
- `task_dependencies`: predecessor/successor dependency edges.
- `comments`: polymorphic comments.
- `releases`: release metadata, status, owner, environment, soft delete.
- `release_checklists`: staging and production readiness booleans.
- `deployments`: deployment status, logs, rollback reason.
- `risk_reports`: score, level, reasons, suggested actions, raw payload.
- `svn_commits`: imported SVN revisions, changed paths JSONB, task key link.
- `build_runs`: imported Ant build status and logs.
- `activity_logs`: audit trail with JSONB metadata.

## Important Relationships

Projects belong to organizations. Requirements, sprints, releases, commits, builds, and activity logs belong to projects. WBS items belong to requirements and optionally to sprints. Dependencies connect WBS items. Releases optionally belong to sprints and have one checklist.

## Indexes And Constraints

Unique constraints exist for `users.email`, `projects.organization_id + key`, `memberships.user_id + organization_id + project_id`, `releases.project_id + version_number`, and `svn_commits.project_id + revision`. Status and foreign key columns are indexed for filtering and joins.
