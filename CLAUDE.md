# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## General agent rules

- When users ask questions, answer them instead of doing the work.

### Language Rules

- Claude prompts and responses: Japanese or English
- Code, comments, commit messages, and documentation: English

### Shell Rules

- Always use `rm -f` (never bare `rm`)
- Run `git` commands in the current directory (do not use the `-C` option)

### Commit Rules

- Always verify changes work before committing (e.g. run `tg-plan` for Terraform, `mise go-build` / `mise go-lint` for Go)
- Never commit without the user's confirmation that the plan/build looks correct

## Project Overview

Gokabot is a LINE chatbot written in Go. It responds to Japanese text messages with features like anime schedules, weather, dictionary lookups, omikuji, and more.

## Repository Structure

- `gokabot-api-go/` - Go backend API
- `infrastructure/` - Terraform/Terragrunt infrastructure (Lightsail)
- `db/` - Database migrations (dbmate)

## Common Commands

### gokabot-api-go (Go Backend)

```bash
# Run tests
mise go-test

# Lint
mise go-lint

# Build
mise go-build

# Run server
mise go-run

# Run server with auto-reload (Air, watches .go, go.mod, go.sum)
# Runs lint and tests before each rebuild
mise go-watch

# Integration test
mise integration-test

# Smoke test — exercises each answerer against real APIs/DB
# Requires: DB running (mise dc-up-db-d), OPEN_WEATHER_API_KEY in .env (optional)
mise go-smoke
```

#### Testing Rules

- Test public interfaces only (exported functions/types)
- Use table-driven tests where appropriate
- Use `want`/`got` naming convention (not `expected`/`actual`)
- Error message format: `got X, want Y`

#### Project Structure

- `cmd/gokabot/main.go` - Application entry point
- `cmd/smoke/main.go` - Smoke test runner (real API/DB calls)
- `internal/answerer/` - Answerer interface and chain-of-responsibility registry
- `internal/answerers/` - All answerer implementations (nyokki, gokabou, anime, weather, webdict, denippi, tex, searchdolls, baseballnews, pigeons)
- `internal/config/` - Configuration loading from environment
- `internal/database/` - Database connection (PostgreSQL)
- `internal/handler/` - HTTP handlers and middleware
- `internal/line/` - LINE Bot client (SDK v8)
- `internal/logger/` - Custom slog logger with emoji

## Architecture

### API Endpoints

- `POST /callback` - Generic callback with JSON body `{msg, user_id, user_name}`
- `POST /line/callback` - LINE webhook endpoint
- `POST /line/push` - Push message to LINE
- `GET /healthCheck` - Health check

### Request Flow

1. Message arrives at `/line/callback` or `/callback`
2. `Registry.Dispatch` iterates through the answerer chain
3. Each answerer's `Answer()` method checks if it should respond
4. First non-nil response wins (truncated to 2000 chars)

## Code Style

### Go (gokabot-api-go)

- Go 1.25
- golangci-lint v2 configured in `.golangci.yml`
- gofumpt + goimports for formatting
