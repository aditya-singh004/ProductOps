# API Contracts

## Rails APIs

`GET /api/projects`

Returns projects the signed-in user can view.

`GET /api/projects/:project_id/sprints`

Returns project sprints.

`GET /api/sprints/:id/board`

Returns sprint metadata, tasks, and summary.

`PATCH /api/wbs_items/:id/status`

```json
{ "status": "in_progress", "blocked_reason": null }
```

`PATCH /api/wbs_items/:id/actual_hours`

```json
{ "actual_hours": 7.5 }
```

`POST /api/wbs_items/:id/dependencies`

```json
{ "predecessor_task_id": 1, "dependency_type": "blocks" }
```

`POST /api/sprints/:id/calculate_risk`

Calls the Java service and stores a `risk_reports` row.

`POST /api/releases/:id/checklist`

```json
{ "qa_verified": true }
```

`POST /api/releases/:id/approve_production`

```json
{ "override_reason": "Accepted by admin after blocker mitigation" }
```

`POST /api/svn/import`

Multipart upload with `project_id` and `svn_log`, or JSON with `project_id` and `xml`.

`POST /api/ant_builds/import`

Multipart upload with `project_id` and `build_log`, or JSON with `project_id` and `log_output`.

## Java Risk API

`POST /api/risk/calculate`

Request:

```json
{
  "sprintId": 12,
  "releaseId": 4,
  "criticalPathTaskIds": [1, 2],
  "tasks": [
    {
      "id": 1,
      "title": "Create DB migration",
      "estimateHours": 8,
      "actualHours": 12,
      "status": "IN_PROGRESS",
      "priority": "HIGH",
      "blocked": false,
      "overdue": true,
      "dependencies": []
    }
  ]
}
```

Response:

```json
{
  "riskScore": 78,
  "riskLevel": "HIGH",
  "reasons": ["1 high-priority tasks are blocked"],
  "suggestedActions": ["Resolve blockers before deployment approval"]
}
```
