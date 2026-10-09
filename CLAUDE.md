# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

"Laverty Pools" — a small Rails 4.2 app for running against-the-spread sports pick pools (primarily NFL). Players join a pool by name (no accounts, no authentication), pick a winner for each match in the pool's date range, and are ranked by how many picks beat the spread.

Ruby 2.2.5, Rails 4.2.7.1, Bootstrap 2.x via `twitter-bootstrap-rails`, LESS for CSS, CoffeeScript + jQuery. Deployed to Heroku (`heroku` remote → `git.heroku.com/lavertypools`), with GitHub (`origin`) as the source of truth.

## Commands

```bash
bundle install
bundle exec rake db:schema:load   # or db:migrate
bundle exec rails server
bundle exec rails console

bundle exec rake test             # all tests
bundle exec rake test:models
bundle exec rake test:controllers
bundle exec ruby -Itest test/models/match_test.rb                      # single file
bundle exec ruby -Itest test/models/match_test.rb -n test_the_truth    # single test
```

There is no linter and the generated test files are almost entirely empty stubs — assume no meaningful test coverage exists.

Deploy with `git push heroku master`. Production uses Postgres (`pg` is in the `:production` group only); development and test use MySQL (`mysql2`), so a local bundle will not install `pg`.

## Domain model

`Sport → League → Team` and `League → Pool`. A `Match` belongs to a league and references two teams via `home_team_id` / `away_team_id` (both `class_name: "Team"`).

The key non-obvious relationship: **a `Pool` has no direct association to matches.** `Pool#matches` is derived at call time from the pool's `start_time`/`end_time` window via the `Match.in_range` scope. Changing a pool's dates silently changes which matches it contains, and any pick rows for matches that fall out of range are orphaned rather than deleted.

Players join pools through the `players_pools` join table (model `PlayersPool`, no timestamps). A `Pick` ties player + pool + match + `winner`.

### Spread and scoring convention

`winner` and `Match#spread_leader` share one integer encoding: **0 = home, 1 = away, -1 = push**. Spread is stored from the home team's perspective — a positive `spread` means the away team is favored. `spread_leader` computes `home_score - away_score + spread` and compares to zero.

`Player#score_for_pool` iterates the pool's matches, skips any that haven't started (`Match#started?`), and awards a point per pick where `pick.winner == match.spread_leader`. It issues a `Pick.find_by` per match (N+1), and `PoolsController#show` calls it once per player, so the leaderboard is O(players × matches) queries.

### Locking

`Pool#locked?` returns true as soon as *any* match in the range has started, which locks the whole pool for everyone — joining and picking both disappear. This is intentional per the git history (see `temporarily unlock pools` / `revert lockout` commits), but note it is an all-or-nothing lock, not per-match.

## Picks flow

`GET /picks/setup?pool_id=&player_name=` (or `player_id=`) is the entry point, and it is **write-on-GET**: it finds-or-creates the `Player`, finds-or-creates the `PlayersPool` membership, and creates a `Pick` row with `winner: 0` for every match in the pool. So every player defaults to picking all home teams. `pools/show` links here both for joining and for editing existing picks.

Picking itself is AJAX: `PicksHelper#pick_link` emits a div with an inline `onclick="setPick(...)"` that checks the matching hidden radio in a hidden `form.ajax` and submits it (`app/assets/javascripts/application.js`). Any change to the pick markup needs to keep the `pick_<id>_row` / `edit_pick_<id>` / `pick_winner_<value>` id contract intact.

## Team logos

Team logos are sprite offsets, not individual images. `pick_link` builds `background-image: url('/images/<league name>.jpg')` and positions it using the team's `logo_offset_x` / `logo_offset_y` columns. Only `public/images/NFL.jpg` exists, so adding a league means adding a matching sprite file named after the league and filling in per-team offsets.

## Time handling

Times are stored in UTC and displayed in `'Eastern Time (US & Canada)'`, hardcoded at each call site (`matches/_match_list.html.erb`, `ApplicationHelper#simple_time`) — `config.time_zone` is not set. `MatchesController` accepts a natural-language date via `Chronic` when `params[:simple_format]` is present (the "simple date" toggle in the match form), and always derives `end_time` as `start_time + 3.hours`. Prefer `Time.zone.now` over `Time.now`; both appear in the codebase.

Note `ApplicationHelper#simple_time` still contains leftover `puts` debugging.

## Gotchas

- Most controllers and views are untouched Rails scaffolding with bootstrap theming; `picks`, `pools`, and `matches` hold all the real logic. `PicksController` only implements `setup` and `update`, even though `routes.rb` also declares a `picks#index` that does not exist.

## Hosting

No longer deployed to Heroku (free tier gone). The app runs for about one week a year, so hosting is spun up and torn down each year rather than kept running — see `RUNBOOK.md` for the yearly restore/backup steps, `Dockerfile` for the deploy image (pins `ruby:2.2.5` since Rails 4.2/Ruby 2.2.5 are both EOL and modern buildpacks/compilers no longer build them cleanly — notably `therubyracer`'s bundled V8), and `render.yaml`/`fly.toml` for the two supported targets. `config/database.yml`'s production block and `config/initializers/secret_token.rb` now read from `DATABASE_URL`/`SECRET_KEY_BASE` env vars rather than hardcoded values, so both files are safe to commit.
