# Gokabot for LINE

[![Check API](https://github.com/23prime/gokabot/workflows/Check%20API/badge.svg)](https://github.com/23prime/gokabot/actions/workflows/check-api.yml)
[![Integration Test Go API](https://github.com/23prime/gokabot/workflows/Integration%20Test%20Go%20API/badge.svg)](https://github.com/23prime/gokabot/actions/workflows/test-go-api.yml)

## What

LINE BOT written in Go, using [line-bot-sdk-go](https://github.com/line/line-bot-sdk-go).

## Usage

Add Gokabot to your friends from the QR code below, and invite to your groups.

![QR](./images/gokabotQR.png)

## Functions

- Calling

  | Send examples         | Response       |
  | --------------------- | -------------- |
  | "ごかぼっと", "ごかぼう", "ヒゲ" | Random message |

- Anime

  | Send examples               | Response                        |
  | --------------------------- | ------------------------------- |
  | "今日", "今日のアニメ", "today"     | Animes in today                 |
  | "昨日", "昨日のアニメ", "yesterday" | Animes in yesterday             |
  | "明日", "明日のアニメ", "tomorrow"  | Animes in tomorrow              |
  | "日曜", "日曜のアニメ", "Sunday"    | Animes in Sunday                |
  | "今期", "今期のアニメ", "all"       | Animes in this term             |
  | "来期", "来期のアニメ", "next"      | Animes in next term             |
  | "おすすめ"                      | Recommended animes in today     |
  | "今期のおすすめ"                   | Recommended animes in this term |

- Weather

  | Send examples | Response                       |
  | ------------- | ------------------------------ |
  | "天気", "今日の天気" | Today's weather in Default     |
  | "明日の天気"       | Tomorrow's weather in Default  |
  | "天気 東京"       | Today's weather in Tokyo       |
  | "明日の天気 東京"    | Tomorrow's weather in Tokyo    |

  Now, Default is Tsukuba.

- Dictionary

  | Send examples          | Response                                                 |
  | ---------------------- | -------------------------------------------------------- |
  | "西郷隆盛ってなに", "西郷隆盛って誰？" | Informations of "西郷隆盛" in Wikipedia or pixiv or niconico |

- Nyokki

  | Send examples | Response          |
  | ------------- | ----------------- |
  | "1ニョッキ"       | Start Nyokki Game |

- Omikuji

  | Send examples | Response          |
  | ------------- | ----------------- |
  | "おみくじ"        | Result of Omikuji |

- Others

  See source code.

## Development

### Pre-required

- [mise](https://mise.jdx.dev): manage tools and tasks
- [Docker](https://www.docker.com)
- [Docker Compose](https://docs.docker.com/compose/)

### Setup and run development server

1. Trust project directory and install tools.

    ```sh
    mise trust -q && mise install
    ```

2. Copy `.env.example` to `.env` and fill in your credentials.

    ```sh
    cp .env.example .env
    # Edit .env and set LINE_CHANNEL_TOKEN and LINE_PUSH_TARGET_ID
    ```

    | Variable | Required for | Description |
    | --- | --- | --- |
    | `LINE_CHANNEL_TOKEN` | Dev server, integration test | Channel access token from LINE Developers console |
    | `LINE_PUSH_TARGET_ID` | Integration test only | LINE user ID to receive test push messages |

3. Run DB migration and seeding

    ```sh
    mise setup-db
    ```

4. Run development server with hot-reloading

    ```sh
    mise dev
    ```

### DB Migration

Use [Dbmate](https://github.com/amacneil/dbmate) for DB schema migration.

Dbmate is managed by mise.

- Prepare: Up DB

    ```sh
    mise dc-up-db
    ```

- Generate a new migration file

    ```sh
    mise dm-new <migration-name>
    ```

- Run any pending migrations

    ```sh
    mise dm
    ```

- Roll back the most recent migration

    ```sh
    mise dm-rb
    ```

- Show the status of all migrations

    ```sh
    mise dm-st
    ```

For more commands, see [Commands](https://github.com/amacneil/dbmate?tab=readme-ov-file#commands).
