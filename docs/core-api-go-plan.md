# core-api Go Rewrite Plan

## Overview

Ruby/Sinatra の core-api を Go で書き直す。標準ライブラリベースで実装。

**New Directory:** `core-api-go/`

## Prerequisites

Tools are managed via mise. Add to `.mise.toml` (repository root):

```toml
[tools]
go = "1.25"
golangci-lint = "2"
hurl = "latest"
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
│   └── test.sql          # Minimal test data (for hurl tests)
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
hurl --test --variable host=http://localhost:8080 tests/api/**/*.hurl
"""
alias = "ta"
```

## Linting

golangci-lint is configured in `.golangci.yml`:

- **Linters:** govet, staticcheck, errcheck, unparam, unused, ineffassign
- **Formatters:** gofmt, goimports

Commands:

```bash
# Run linter
golangci-lint run

# Run with auto-fix
golangci-lint run --fix
```

## Project Structure

```
core-api-go/
├── .golangci.yml                 # Linter config
├── cmd/gokabot/main.go           # Entry point
├── internal/
│   ├── answerer/
│   │   ├── answerer.go           # Interface definition
│   │   ├── answerer_test.go      # Unit tests
│   │   └── registry.go           # Answerer chain (first non-nil wins)
│   ├── answerers/                # All 10 answerers (each with *_test.go)
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
│   ├── database/
│   │   ├── db.go
│   │   └── models/               # animes, cities, gokabous
│   ├── handler/                  # HTTP handlers
│   ├── line/                     # LINE Bot client (signature validation, reply/push)
│   ├── markov/                   # Markov chain for Gokabou
│   └── config/
├── go.mod
└── Dockerfile
```

## Dependencies

```go
require (
    github.com/lib/pq v1.10.9                    // PostgreSQL driver
    github.com/PuerkitoBio/goquery v1.8.1       // HTML parsing (web scraping)
    github.com/ikawaha/kagome/v2 v2.9.0         // Japanese tokenizer (MeCab alternative)
)
```

- `lib/pq`: PostgreSQL driver (standard database/sql interface)
- `goquery`: HTML parsing for web scraping (WebDict, BaseballNews, DflSearch)
- `kagome`: Pure Go Japanese tokenizer (Gokabou Markov chain)

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

**E2E tests (minimal):** hurl で LINE 署名検証のみ確認

```
tests/
└── api/
    └── line/
        └── callback.hurl       # LINE webhook signature validation
```

```bash
mise test-api
```

## Implementation Phases

### Phase 0: Setup

- [x] Create `.mise.toml` at repository root
  - [x] Run `mise use dbmate@2`
- [x] Create `db/migrations/` directory
- [x] Add mise tasks for DB migration.
- [ ] Write initial migrations for animes, cities, gokabous tables
  - [x] Run `mise dm-new create_schema_gokabot`
  - [x] Run `mise dm-new create_table_animes`
  - [x] Run `mise dm-new create_table_cities`
  - [x] Run `mise dm-new create_table_gokabous`
- [x] Create `db/seeds/` directory
  - [x] Write `db/seeds/test.sql` for hurl tests
  - [x] Add mise tasks for seeding (`db-seed`, `db-seed-test`)
- [x] Create `tests/api/` directory structure
  - [x] Config Hurl with Docker Compose
  - [x] Add mise tasks for testing (`test-api`)
- [x] Write hurl test for LINE signature validation

### Phase 1: Foundation

- [ ] Go module setup (`go mod init`)
- [ ] Config loading from environment variables
- [ ] Logger setup
- [ ] Database connection (`database/sql` + `lib/pq`)
- [ ] 3 models: Anime, City, Gokabou
- [ ] Basic HTTP server with `net/http`
- [ ] Answerer interface and Registry

### Phase 2: Simple Answerers

- [ ] Nyokki - counting game
- [ ] Denippi - word chain game
- [ ] Tex - LaTeX URL builder
- [ ] Pigeons - CSV random picker

### Phase 3: Database Answerers

- [ ] Anime - schedule queries
- [ ] Weather - OpenWeatherMap API + Cities DB

### Phase 4: Web Scraping Answerers

- [ ] DflSearch - Wikiwiki CDN URL builder
- [ ] WebDict - Niconico, Pixiv, Wikipedia scraping
- [ ] BaseballNews - Yahoo Baseball scraping

### Phase 5: Markov Chain

- [ ] Kagome tokenizer integration
- [ ] Markov chain builder/generator
- [ ] Gokabou answerer (patterns + Markov)

### Phase 6: LINE Integration

- [ ] LINE webhook signature validation (HMAC-SHA256)
- [ ] LINE reply message
- [ ] LINE push message

### Phase 7: Finalization

- [ ] Unit tests for all answerers
- [ ] Integration tests
- [ ] Dockerfile
- [ ] README

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

- `DATABASE_URL`
- `LINE_CHANNEL_SECRET`
- `LINE_CHANNEL_TOKEN`
- `OPEN_WEATHER_API_KEY`

## Verification

1. Run `golangci-lint run` - No lint errors
2. Run `go build ./cmd/gokabot` - Build succeeds
3. Run `go test ./...` - All unit tests pass
4. Run `mise test-api` - LINE signature validation test passes
