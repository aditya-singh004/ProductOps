# ProductOps

Engineering Delivery & Release Intelligence Platform.

ProductOps is a production-style monorepo for software teams to manage product requirements, requirement gaps, WBS estimates, sprint execution, task dependencies, release checklists, SVN commit tracking, Ant build logs, and release risk scoring with a Java 17 Maven microservice.

## Problem Statement

Delivery risk is often spread across requirements documents, sprint boards, build logs, commits, release checklists, and tribal knowledge. ProductOps brings those signals into one Rails application and delegates deterministic sprint/release risk scoring to a separate Java service.

## Why This Project Exists

This project is designed as a resume-grade engineering system for demonstrating Ruby on Rails, PostgreSQL schema design, role-based access, ERB/jQuery interfaces, service objects, Java 17, Maven, Ant, SVN log parsing, Docker, CI, and dependency graph algorithms.

## Tech Stack

| Area | Technology |
| --- | --- |
| Main app | Ruby on Rails, ERB, ActiveRecord |
| Database | PostgreSQL, JSONB, foreign keys, indexes |
| Frontend | HTML, CSS, jQuery |
| Risk service | Java 17, Spring Boot, Maven, JUnit |
| Legacy module | Java, Ant, build.xml |
| DevOps | Docker, Docker Compose, GitHub Actions |

## Architecture

```text
Browser
  -> Rails ERB/jQuery app
      -> PostgreSQL
      -> RiskEngineClient
          -> Java Spring Boot risk-engine-service
      -> SVN XML parser
      -> Ant build log parser
```

## Monorepo Structure

```text
rails-app/              Rails app, migrations, services, ERB, tests
risk-engine-service/    Java 17 Spring Boot Maven service
legacy-build-module/    Ant-based legacy Java sample module
sample-data/            SVN XML and Ant build logs
docs/                   Architecture, schema, API, algorithm notes
.github/workflows/      CI for Rails, Java, and Ant
docker-compose.yml      Rails, PostgreSQL, Java service
```

## Core Features

- Authentication with secure password hashing and demo users.
- Role-based access for Admin, Project Manager, Developer, QA, and Client Viewer.
- Projects, requirements, gaps, clarification questions, decisions, and meeting notes.
- WBS estimates with actual effort, variance, blockers, overdue detection, and progress.
- Kanban-style sprint board with jQuery status updates.
- Dependency graph services for cycle detection, topological sort, critical path, and blocker propagation.
- Release checklists, deployment timeline, production approval rules, and audit logging.
- Java risk engine integration with persisted risk reports.
- SVN XML import with `PO-123` task-key linking.
- Ant build log import with build history and release risk signals.

## Database Schema Summary

The Rails app uses normalized PostgreSQL tables: `users`, `organizations`, `memberships`, `projects`, `requirements`, `requirement_gaps`, `clarification_questions`, `decision_notes`, `meeting_notes`, `sprints`, `wbs_items`, `task_dependencies`, `comments`, `releases`, `release_checklists`, `deployments`, `risk_reports`, `svn_commits`, `build_runs`, and `activity_logs`.

Important constraints include unique user email, unique project key per organization, unique release version per project, unique SVN revision per project, foreign keys, status indexes, and soft-delete columns for projects, requirements, WBS items, and releases.

## Java Risk Engine

Rails sends sprint task payloads to:

```text
POST http://risk-engine-service:8080/api/risk/calculate
```

The Java service returns a deterministic `riskScore`, `riskLevel`, explainable `reasons`, and `suggestedActions`. Scoring considers blocked high-priority tasks, overdue work, actual-vs-estimate variance, critical path delay, pending high-priority tasks, and blocked dependencies.

## Dependency Graph Algorithms

- Cycle detection: DFS rejects circular task dependencies.
- Topological sort: produces a recommended execution order.
- Critical path: computes the longest estimated-hour dependency chain.
- Blocker propagation: highlights downstream tasks at risk when predecessors are blocked.

## SVN Import

ProductOps imports XML from:

```bash
svn log --xml
```

The parser extracts revision, author, date, message, changed paths, and task keys like `PO-102`, then links commits to matching WBS items.

## Ant Build Logs

The legacy module includes `build.xml`, sample Java source, tests, and success/failure logs. Rails parses imported logs to track build status, duration, failed tests, and release warnings.

## Setup

```bash
cd productops
cp .env.example .env
docker compose build
docker compose up
```

In another terminal:

```bash
docker compose exec rails-app rails db:create db:migrate db:seed
```

Open:

```text
http://localhost:3000
```

## Tests

```bash
docker compose exec rails-app rails test
docker compose exec risk-engine-service mvn test
cd legacy-build-module && ant clean test
```

## Demo Credentials

| Role | Email | Password |
| --- | --- | --- |
| Admin | admin@productops.dev | password123 |
| Project Manager | pm@productops.dev | password123 |
| Developer | dev@productops.dev | password123 |
| QA | qa@productops.dev | password123 |
| Client Viewer | client@productops.dev | password123 |

## API Endpoints

- `GET /api/projects`
- `GET /api/projects/:project_id/sprints`
- `GET /api/sprints/:id/board`
- `PATCH /api/wbs_items/:id/status`
- `PATCH /api/wbs_items/:id/actual_hours`
- `POST /api/wbs_items/:id/dependencies`
- `DELETE /api/wbs_items/:id/dependencies/:dependency_id`
- `POST /api/sprints/:id/calculate_risk`
- `POST /api/releases/:id/checklist`
- `POST /api/releases/:id/approve_production`
- `POST /api/svn/import`
- `POST /api/ant_builds/import`
- Java: `POST /api/risk/calculate`

## Screenshots

<img width="2880" height="1630" alt="image" src="https://github.com/user-attachments/assets/e23bf969-c986-4c0b-a58b-7e4eec87ba8d" />

## Production-Grade Highlights

- Service objects keep controllers small.
- PostgreSQL constraints protect integrity.
- Authorization checks gate sensitive actions.
- Audit logs record release and import actions.
- Docker Compose provides reproducible local infrastructure.
- CI runs Rails tests, Maven tests, and Ant build checks.

