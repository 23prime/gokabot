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
│   │   └── registry.go           # Answerer chain (first non-nil wins)
│   ├── answerers/                # All 10 answerers
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
│   ├── line/                     # LINE Bot client
│   ├── discord/                  # Discord client
│   ├── markov/                   # Markov chain for Gokabou
│   └── config/
├── docs/                         # Copy from core-api/docs
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

## API Testing (hurl)

Test files location: `tests/api/`

```
tests/
└── api/
    ├── callback.hurl           # Generic callback tests
    ├── answerers/
    │   ├── nyokki.hurl
    │   ├── gokabou.hurl
    │   ├── anime.hurl
    │   ├── weather.hurl
    │   ├── webdict.hurl
    │   ├── denippi.hurl
    │   ├── tex.hurl
    │   ├── pigeons.hurl
    │   ├── dflsearch.hurl
    │   └── baseballnews.hurl
    └── line/
        └── callback.hurl       # LINE webhook tests
```

Run tests against both implementations:

```bash
# Test Ruby implementation (default port 8080)
hurl --test --variable host=http://localhost:8080 tests/api/*.hurl

# Test Go implementation (port 8081)
hurl --test --variable host=http://localhost:8081 tests/api/*.hurl
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
  - [ ] Run `mise dm-new create_table_cities`
  - [ ] Run `mise dm-new create_table_gokabous`
- [ ] Create `tests/api/` directory structure
- [ ] Write hurl tests for `/callback` endpoint
- [ ] Write hurl tests for each answerer
- [ ] Verify tests pass against Ruby implementation

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

### Phase 6: API Integrations

- [ ] LINE webhook signature validation (HMAC-SHA256)
- [ ] LINE reply/push message
- [ ] Discord push message

### Phase 7: Finalization

- [ ] Unit tests for all answerers
- [ ] Integration tests
- [ ] Dockerfile
- [ ] README

## API Endpoints (same as Ruby)

- `POST /callback` - Generic callback `{msg, user_id, user_name}`
- `POST /line/callback` - LINE webhook
- `POST /line/push` - LINE push message
- `POST /discord/push` - Discord push message

## Key Files to Reference

- `core-api/app/controllers.rb` - HTTP routes
- `core-api/app/core.rb` - Answerer initialization order
- `core-api/app/line/callback/reply_to_text.rb` - Message processing loop
- `core-api/app/core/gokabou/gen_msg.rb` - Markov chain logic
- `core-api/app/core/web_dict/web_dict.rb` - Web scraping pattern

## Environment Variables

Same as Ruby version:

- `DATABASE_URL`
- `LINE_CHANNEL_SECRET`
- `LINE_CHANNEL_TOKEN`
- `DISCORD_BOT_TOKEN`
- `DISCORD_TARGET_CHANNEL_ID`
- `OPEN_WEATHER_API_KEY`

## Verification

1. Run `golangci-lint run` - No lint errors
2. Run `go build ./cmd/gokabot` - Build succeeds
3. Run `go test ./...` - All unit tests pass
4. Run `hurl --test tests/api/*.hurl` against Go implementation - All API tests pass
5. Compare hurl test results between Ruby and Go implementations
