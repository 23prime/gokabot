# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language Rules

- Claude prompts and responses: Japanese or English
- Code, comments, commit messages, and documentation: English

## Project Overview

Gokabot is a LINE/Discord chatbot written in Ruby with a Vue.js demo frontend. It responds to Japanese text messages with features like anime schedules, weather, dictionary lookups, omikuji, and more.

## Repository Structure

- `core-api/` - Ruby/Sinatra backend API (legacy)
- `gokabot-api-go/` - Go backend API (new)
- `gokabot-demo/` - Vue.js 3 + TypeScript frontend demo
- `terraform/` - Experimental (can be ignored)

## Common Commands

### core-api (Ruby Backend)

```bash
# Run tests
cd core-api && bundle exec rspec

# Run a single test file
cd core-api && bundle exec rspec spec/app/core/anime_spec.rb

# Lint
cd core-api && bundle exec rubocop

# Auto-fix lint issues
cd core-api && bundle exec rubocop -a

# Run locally with Docker
mise build
mise dev

# Run tests in Docker (used by CI)
docker compose -f docker-compose.api-test.yml run --rm gokabot-core-local rspec
```

### gokabot-demo (Vue Frontend)

```bash
cd gokabot-demo

# Dev server (http://localhost:3000)
yarn vite

# Build
yarn vite build

# Lint
yarn lint

# Type check
yarn tsc
```

### gokabot-api-go (Go Backend)

```bash
# Run tests
mise go-test

# Lint
mise go-lint

# Build
mise go-build
```

#### Testing Rules

- Test public interfaces only (exported functions/types)
- Use table-driven tests where appropriate

## Architecture

### core-api

**Entry Points:**

- `app/controllers.rb` - Sinatra routes for all API endpoints
- `app/core.rb` - Initializes answerer objects (`$ANS_OBJS` array)

**Request Flow:**

1. Message arrives at `/line/callback` or `/callback`
2. `Line::Callback::ReplyToText#mk_reply_text` iterates through `$ANS_OBJS`
3. Each answerer's `answer()` method checks if it should respond
4. First non-nil response wins (truncated to 2000 chars)

**Answerer Pattern:**
All answerers in `app/core/` implement an `answer(*msg_data)` method that returns:

- A string response if the message matches
- `nil` to pass to the next answerer

Current answerers (in priority order): Nyokki, Gokabou, Anime, Weather, WebDict, Denippi, Tex, Pigeons, DflSearch, BaseballNews

**Key Directories:**

- `app/core/` - Message answerer modules
- `app/line/` - LINE Bot API integration
- `app/discord/` - Discord Bot integration
- `app/models/` - ActiveRecord models (Animes, Cities, Gokabous)

### API Endpoints

- `POST /callback` - Generic callback with JSON body `{msg, user_id, user_name}`
- `POST /line/callback` - LINE webhook endpoint
- `POST /line/push` - Push message to LINE
- `POST /discord/push` - Push message to Discord

## Code Style

### Ruby (core-api)

- Target Ruby 2.7.6
- Line length max 120
- RuboCop configured in `.rubocop.yml`
- Specs exclude from `Metrics/BlockLength`

### TypeScript/Vue (gokabot-demo)

- ESLint + Prettier
- Vue 3 with TypeScript
