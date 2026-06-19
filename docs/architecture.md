# Architecture

ProductOps is a monorepo with a Rails web application, PostgreSQL database, Java risk microservice, and legacy Ant module.

## Components

- Rails app: authentication, RBAC, product workflow, ERB views, jQuery interactions, JSON APIs, service objects, and tests.
- PostgreSQL: normalized relational schema with foreign keys, indexes, uniqueness constraints, JSONB metadata, and soft delete fields.
- Java risk engine: Spring Boot REST API that scores sprint/release risk from task data.
- SVN parser: Rails service that safely parses `svn log --xml` output with REXML.
- Ant parser: Rails service that imports build logs from legacy Java builds.
- Legacy build module: standalone Java source and Ant `build.xml`.

## Risk Calculation Flow

```text
User clicks Calculate Risk
  -> Rails API /api/sprints/:id/calculate_risk
  -> RiskEngineClient builds task payload
  -> POST /api/risk/calculate on Java service
  -> Java returns score, level, reasons, actions
  -> Rails stores risk_reports row
  -> Sprint/release UI displays latest report
```

## Deployment Architecture

Docker Compose starts:

- `postgres` on port 5432
- `risk-engine-service` on port 8080
- `rails-app` on port 3000

Rails reaches the Java service through `http://risk-engine-service:8080`.
