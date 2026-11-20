# Local API – experimental

Run from the repository root:

```bash
python -m services.api.server
```

Binds to 127.0.0.1:8788 only. Data stored in `data/planner.sqlite` (exclude this directory from Git). No external dependencies.

- `GET /health` readiness response
- `GET /tasks` list persisted tasks
- `POST /tasks` create/update task: `{"id":"a","title":"Example","minutes":30}`
- `POST /plan` plan open tasks: `{"start":"2026-11-21T09:00:00+01:00","end":"2026-11-21T17:00:00+01:00"}`

**Not production ready.** No authentication, TLS, user isolation, fixed-calendar event API, migrations or concurrency versioning. Never bind to public interfaces or expose via Oracle/Nginx. The API intentionally rejects non-loopback hosts. Offline task storage remains available if the server is stopped.
