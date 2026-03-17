# gokabot-api-go

Go rewrite of the Ruby/Sinatra `core-api`. Handles LINE Bot webhooks and
responds to Japanese text messages with various features.

## Requirements

- Go 1.25+
- PostgreSQL
- [mise](https://mise.jdx.dev/) for task management

## Setup

```bash
# Install tools
mise install

# Start database
mise dc-up-db-d

# Run database migrations and seed
mise db-migrate
mise db-seed

# Copy and fill in secrets
cp .env.example .env
```

### Environment Variables

| Variable | Required | Description |
|---|---|---|
| `DATABASE_URL` | ✅ | PostgreSQL connection string |
| `LINE_CHANNEL_SECRET` | ✅ | LINE Bot channel secret |
| `LINE_CHANNEL_TOKEN` | ✅ | LINE Bot channel access token |
| `OPEN_WEATHER_API_KEY` | optional | OpenWeatherMap API key (Weather answerer) |
| `GOKABOU_USER_ID` | optional | LINE user ID whose messages train the Markov dict |
| `PORT` | optional | HTTP port (default: 8080) |
| `LOG_LEVEL` | optional | `DEBUG`, `INFO`, `WARN`, `ERROR` (default: INFO) |

## Running

```bash
# Run server
mise go-run

# Run with live reload (lint + test before each rebuild)
mise go-watch
```

## Testing

```bash
# Unit tests
mise go-test

# Lint
mise go-lint

# Vulnerability scan + lint + unit tests
mise go-check

# Integration tests (requires Docker)
mise integration-test

# Smoke tests against real APIs and DB (requires DATABASE_URL and running DB)
mise go-smoke
```

## API Endpoints

| Method | Path | Description |
|---|---|---|
| `GET` | `/healthCheck` | Returns DB health status |
| `POST` | `/line/callback` | LINE webhook (HMAC-SHA256 signature validation) |
| `POST` | `/line/push` | Push a message to a LINE user |

### POST /line/push

```json
{ "target_id": "<LINE user ID>", "msg": "<message text>" }
```

## Answerers

Messages are dispatched through a chain of answerers in priority order.
The first non-nil response wins (truncated to 2000 characters).

| Answerer | Trigger | Description |
|---|---|---|
| **nyokki** | `<N>にょっき` | Counting game; loses on duplicates |
| **gokabou** | `ごかぼう`, `gokabot`, `ヒゲ`, `おみくじ`, etc. | Fixed responses + Markov chain text generation |
| **anime** | `今期`, `all`, `mon`, `今日`, etc. | Anime schedule from DB |
| **weather** | `天気`, `今日の天気`, `明日の天気` | Current weather via OpenWeatherMap |
| **webdict** | `<word>とは`, `<word>って？` | Dictionary lookup (Niconico → Pixiv → Wikipedia) |
| **denippi** | Single kana, `うん` | Replies with random kana every 2nd message |
| **tex** | `$<formula>$` | LaTeX → Google Charts image URL |
| **searchdolls** | `doll <name>`, `doll damage <name>` | Girls' Frontline doll image from wikiwiki.jp |
| **baseballnews** | `野球`, `野球速報`, `野球 <team>` | Today's NPB game scores from npb.jp |
| **pigeons** | `鳩` | Random mail from yukarin_mails DB table |

## Project Structure

```
gokabot-api-go/
├── cmd/
│   ├── gokabot/main.go      # Server entry point
│   └── smoke/main.go        # Smoke test runner
├── internal/
│   ├── answerer/            # Interface + Registry (chain-of-responsibility)
│   ├── answerers/           # All answerer implementations
│   │   ├── anime/
│   │   ├── baseballnews/
│   │   ├── denippi/
│   │   ├── gokabou/
│   │   ├── nyokki/
│   │   ├── pigeons/
│   │   ├── searchdolls/
│   │   ├── tex/
│   │   ├── weather/
│   │   └── webdict/
│   ├── config/              # Environment variable loading
│   ├── database/            # PostgreSQL connection
│   ├── handler/             # HTTP handlers and middleware
│   ├── line/                # LINE Bot client (SDK v8)
│   └── logger/              # slog with emoji prefixes
└── tests/                   # runn integration test scenarios
```
