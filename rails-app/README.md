# ProductOps Rails App

Server-rendered Ruby on Rails application for requirements, WBS, sprints, releases, SVN imports, Ant build history, audit logs, and risk reports.

Run from the repository root with Docker Compose:

```bash
docker compose build
docker compose up
docker compose exec rails-app rails db:create db:migrate db:seed
```
