# core-api Go Rewrite Plan

## Overview

Ruby/Sinatra の core-api を Go で書き直す。標準ライブラリベースで実装。

**New Directory:** `gokabot-api-go/`

## Prerequisites

Tools are managed via mise. Add to `.mise.toml` (repository root):

```toml
[tools]
go = "1.25"
golangci-lint = "2"
dbmate = "latest"
```

Setup:

```bash
mise install
```

## Database Migrations (dbmate)

Migration files location: `db/migrations/`

```
db/
├── migrations/
│   ├── 20240101000000_create_animes.sql
│   ├── 20240101000001_create_cities.sql
│   └── 20240101000002_create_gokabous.sql
└── schema.sql                    # Auto-generated schema dump
```

Commands:

```bash
# Create new migration
dbmate new create_users

# Run migrations
dbmate up

# Rollback last migration
dbmate down

# Dump schema
dbmate dump
```

Environment variable: `DATABASE_URL=postgres://postgres:password@localhost:5432/gokabot_db?sslmode=disable`

## Seed Data

Seed files location: `db/seeds/`

```
db/
├── migrations/
├── seeds/
│   ├── development.sql   # Development data
│   └── test.sql          # Minimal test data (for integration tests)
└── schema.sql
```

### test.sql Guidelines

- Keep minimal data needed for each answerer test
- Make idempotent (`TRUNCATE` + `INSERT` or `ON CONFLICT DO NOTHING`)

```sql
-- Example: db/seeds/test.sql
TRUNCATE gokabot.animes, gokabot.cities, gokabot.gokabous RESTART IDENTITY;

INSERT INTO gokabot.cities (id, name, jp_name) VALUES
(1850147, 'Tokyo', '東京');

INSERT INTO gokabot.animes (year, season, day, time, station, title, recommend) VALUES
(2026, 'winter', 'Mon', '24:00', 'TOKYO MX', 'Test Anime', true);
```

### mise Tasks for Seeds

```toml
[tasks.db-seed]
run = "psql $DATABASE_URL -f db/seeds/development.sql"
alias = "dm-sd"

[tasks.db-seed-test]
run = "psql $DATABASE_URL -f db/seeds/test.sql"
alias = "dm-sd-test"

[tasks.test-api]
run = """
dbmate up
psql $DATABASE_URL -f db/seeds/test.sql
runn run gokabot-api-go/tests/*.yaml --runner req:http://localhost:8081
"""
alias = "ta"
```

## Linting

golangci-lint is configured in `.golangci.yml`:

- **Linters:** govet, staticcheck, errcheck, unused, gosec, bidichk, errorlint, bodyclose, unconvert, usestdlibvars, modernize, exhaustive
- **Formatters:** gofumpt, goimports
- **Note:** `unused.parameters-are-used: false` — unused parameters are flagged; interface methods should omit parameter names, implementations should use parameters (e.g. pass `ctx` to `WithContext`)

Commands:

```bash
mise go-lint
```

## Project Structure

```
gokabot-api-go/
├── .golangci.yml                 # Linter config
├── cmd/gokabot/main.go           # Entry point
├── internal/
│   ├── config/                   # Config loading from environment (DONE)
│   ├── database/                 # PostgreSQL connection (DONE)
│   │   └── db.go
│   ├── handler/                  # HTTP handlers (DONE)
│   │   ├── health.go
│   │   ├── line_callback.go      # POST /line/callback (echo reply)
│   │   ├── line_push.go          # POST /line/push
│   │   └── middleware.go         # RequestLog
│   ├── line/                     # LINE Bot client (DONE)
│   │   └── client.go             # Client interface + LINE Bot SDK v8 impl
│   ├── logger/                   # slog with emoji (DONE)
│   ├── answerer/                 # (Phase 3) Interface + Registry
│   │   ├── answerer.go
│   │   └── registry.go
│   ├── answerers/                # (Phase 4-7) All 10 answerers
│   │   ├── nyokki/
│   │   ├── gokabou/
│   │   ├── anime/
│   │   ├── weather/
│   │   ├── webdict/
│   │   ├── denippi/
│   │   ├── tex/
│   │   ├── pigeons/
│   │   ├── dflsearch/
│   │   └── baseballnews/
│   ├── database/models/          # (Phase 3) animes, cities, gokabous
│   └── markov/                   # (Phase 7) Markov chain for Gokabou
├── tests/
│   ├── health-check.yaml
│   ├── line-callback.yaml
│   └── line-push.yaml            # (DONE)
├── go.mod
└── Dockerfile.dev
```

## Dependencies

Current (`go.mod`):

```go
require (
    github.com/DATA-DOG/go-sqlmock v1.5.2        // DB mock for tests
    github.com/google/uuid v1.6.0                // Request ID generation
    github.com/lib/pq v1.10.9                    // PostgreSQL driver
    github.com/line/line-bot-sdk-go/v8 v8.19.0  // LINE Bot SDK
)
```

Planned additions:

```go
require (
    github.com/PuerkitoBio/goquery v1.8.1        // HTML parsing (Phase 6: WebDict, BaseballNews, DflSearch)
    github.com/ikawaha/kagome/v2 v2.9.0          // Japanese tokenizer (Phase 7: Gokabou Markov chain)
)
```

## Answerer Interface

```go
type MessageData struct {
    Message  string
    UserID   string
    UserName string
}

type Response struct {
    Text      string
    ReplyType string // "text" or "image"
}

type Answerer interface {
    Answer(data MessageData) *Response
}
```

## Testing Strategy

**Unit tests (primary):** Go の標準テストで各 answerer のロジックを網羅

```bash
go test ./...
```

**E2E tests (minimal):** runn で HTTP レベルの動作を確認

```
gokabot-api-go/tests/
├── health-check.yaml           # Health check endpoint
├── line-callback.yaml          # LINE webhook signature validation
└── line-push.yaml              # POST /line/push (LINE_PUSH_TARGET_ID が空の場合は実プッシュをスキップ)
```

```bash
mise integration-test
```

## Implementation Phases

### Phase 0: Setup (DONE)

- [x] `.mise.toml` with Go, golangci-lint, dbmate
- [x] DB migrations (`db/migrations/`) for schema, animes, cities, gokabous
- [x] DB seeds (`db/seeds/test.sql`) with mise tasks
- [x] runn integration test framework (`gokabot-api-go/tests/`)

### Phase 1: Foundation (DONE)

- [x] Go module, linter, formatter, unit test config
- [x] Dockerfile + Dockerfile.dev + Docker Compose
- [x] CI/CD (`test-go-api.yml`) with Docker-based integration tests
- [x] Air hot-reload (`mise go-watch`)
- [x] Config loading from environment variables
- [x] Logger setup (slog with emoji)
- [x] Basic HTTP server with `net/http` + health check
- [x] Database connection (`database/sql` + `lib/pq`)

### Phase 2: LINE Integration (DONE)

- [x] LINE webhook signature validation (HMAC-SHA256)
- [x] LINE reply message (`internal/line` — LINE Bot SDK v8)
- [x] LINE push message (`internal/line` — LINE Bot SDK v8)
- [x] `POST /line/callback` handler (signature validation + echo reply)
- [x] `POST /line/push` handler
- [x] `LINE_CHANNEL_TOKEN` を必須環境変数として config に追加
- [x] `.env` / `.env.example` セットアップ、CI workflow に Secrets 注入

### Phase 3: Core Framework (DONE)

- [x] Answerer interface and Registry
- [x] Wire answerer chain into `/line/callback`

### Phase 4: Simple Answerers (DONE)

- [x] Nyokki - counting game
- [x] Denippi - word chain game
- [x] Tex - LaTeX URL builder
- [x] Pigeons - yukarin_mails DB table

### Phase 5: Database Answerers (DONE)

- [x] Anime - schedule queries
- [x] Weather - OpenWeatherMap API + Cities DB

### Phase 6: Web Scraping Answerers (DONE)

- [x] SearchDolls - Wikiwiki CDN URL builder (note: DflSearch renamed)
- [x] WebDict - Niconico, Pixiv, Wikipedia scraping
- [x] BaseballNews - npb.jp scraping (Yahoo Baseball was broken)

### Phase 7: Markov Chain (DONE)

- [x] Kagome tokenizer integration (kagome/v2 with IPA dict)
- [x] Markov chain builder/generator (3-gram, sentinel boundaries)
- [x] Gokabou answerer (fixed patterns + Markov)

### Phase 8: Finalization (DONE)

- [x] README (`gokabot-api-go/README.md`)
- [x] Smoke test runner (`cmd/smoke/main.go`, `mise go-smoke`)
- [x] `.gitignore` cleanup

## API Endpoints

- `POST /line/callback` - LINE webhook (with X-Line-Signature validation)
- `POST /line/push` - LINE push message (internal use)

## Key Files to Reference

- `core-api/app/controllers.rb` - HTTP routes
- `core-api/app/core.rb` - Answerer initialization order
- `core-api/app/line/callback/reply_to_text.rb` - Message processing loop
- `core-api/app/core/gokabou/gen_msg.rb` - Markov chain logic
- `core-api/app/core/web_dict/web_dict.rb` - Web scraping pattern

## Environment Variables

Required (server won't start without these):

- `DATABASE_URL`
- `LINE_CHANNEL_SECRET`
- `LINE_CHANNEL_TOKEN` — copy `.env.example` to `.env` and fill in the value

Optional:

- `PORT` (default: 8080)
- `LOG_LEVEL` (default: INFO)
- `LINE_PUSH_TARGET_ID` — integration test only; push step is skipped if empty
- `OPEN_WEATHER_API_KEY` — required for Weather answerer (Phase 5)

## Verification

```bash
mise go-test    # Unit tests
mise go-lint    # Lint
mise go-build   # Build
mise integration-test  # Integration tests (requires .env)
```
