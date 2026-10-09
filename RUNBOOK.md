# Yearly spin-up / teardown runbook

This app is meant to exist for about one week a year (whenever the pool
runs) and cost nothing the rest of the time. That means recreating hosting
from scratch each year instead of leaving it provisioned. Pick one of the
two paths below.

Prerequisite: Postgres command-line tools (`pg_dump`/`pg_restore`) on your
own machine — `brew install libpq && brew link --force libpq` on macOS.

## Option A: Render (free, recommended default)

### Spin up for the pool

1. In the Render dashboard: **New → Blueprint**, point it at this repo.
   `render.yaml` creates the web service and a free Postgres database and
   wires `DATABASE_URL`/`SECRET_KEY_BASE` automatically.
2. First build compiles `therubyracer`'s bundled V8 from source — expect
   10–20 minutes, not a hang.
3. Once the database is up, grab its **External Connection String** from
   the Render dashboard and restore last year's data:
   ```bash
   pg_restore --no-owner --no-privileges --clean --if-exists \
     -d "<external connection string>" latest.dump
   ```
4. Visit the deployed URL, confirm pools/matches/picks look right.

### Tear down after the pool

1. Back up the season's data before it's gone:
   ```bash
   pg_dump --format=custom --no-owner --no-privileges \
     -f latest.dump "<external connection string>"
   ```
   Commit this as the new `latest.dump` (or wherever you keep backups —
   it's gitignored, so don't rely on git history for it).
2. Delete the Blueprint's services from the Render dashboard (or just leave
   them — the free Postgres instance expires and is deleted automatically
   30 days after creation regardless, and the free web service costs
   nothing while idle).

## Option B: Fly.io (if Render's cold start is annoying mid-pool)

### Spin up for the pool

```bash
fly launch --no-deploy          # creates the app from fly.toml, skip deploy
fly postgres create             # separate small Postgres cluster
fly postgres attach <pg-app-name>   # wires DATABASE_URL as a secret
fly secrets set SECRET_KEY_BASE="$(ruby -rsecurerandom -e 'print SecureRandom.hex(64)')"
fly deploy
```

Restore the backup (Fly Postgres isn't publicly reachable by default, so
proxy to it first):

```bash
fly proxy 5432 -a <pg-app-name> &
pg_restore --no-owner --no-privileges --clean --if-exists \
  -d "postgresql://postgres:<password from fly postgres attach output>@localhost:5432/<db-name>" \
  latest.dump
```

### Tear down after the pool

```bash
fly proxy 5432 -a <pg-app-name> &
pg_dump --format=custom --no-owner --no-privileges \
  -f latest.dump "postgresql://postgres:<password>@localhost:5432/<db-name>"

fly apps destroy lavertypools
fly apps destroy <pg-app-name>
```

Destroying (not just scaling to zero) is what keeps the off-season cost at
$0 — a stopped machine with its volume still attached keeps billing for
storage.

## Notes

- `SECRET_KEY_BASE` is generated fresh each time you provision (Render via
  `generateValue: true`, Fly via the `fly secrets set` command above).
  That's fine — it only needs to be stable for the life of one deployment,
  not across years.
- The dump files in this repo are gitignored on purpose (`*.dump`) — they
  contain real player names/picks. Keep your own copy of `latest.dump`
  somewhere safe between years.
