# Core API Specification

## Overview

Gokabot Core API is a chatbot backend that processes messages and returns responses. It supports LINE Bot webhook, Discord push messages, and a generic callback endpoint.

**Base URL:** `http://localhost:8080`

---

## Endpoints

### POST /callback

Generic callback endpoint for processing messages.

**Request:**

```json
{
  "msg": "今日の天気",
  "user_id": "U1234567890",
  "user_name": "testuser"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| msg | string | Yes | Message text to process |
| user_id | string | Yes | User identifier |
| user_name | string | Yes | User display name |

**Response:**

```json
{
  "type": "text",
  "text": "東京の天気は晴れです。気温は15°Cです。"
}
```

| Field | Type | Description |
|-------|------|-------------|
| type | string | Response type: `text` or `image` |
| text | string | Response text (max 2000 chars) |
| originalContentUrl | string | Image URL (when type=image) |
| previewImageUrl | string | Preview image URL (when type=image) |

**Status Codes:**

- `200 OK` - Success
- `400 Bad Request` - Missing required fields

---

### POST /line/callback

LINE Bot webhook endpoint. Receives events from LINE platform.

**Headers:**

| Header | Required | Description |
|--------|----------|-------------|
| X-Line-Signature | Yes | HMAC-SHA256 signature for validation |

**Request Body:** LINE webhook event object (see [LINE Messaging API](https://developers.line.biz/en/reference/messaging-api/#webhook-event-objects))

**Response:**

- `200 OK` - Always return 200 to acknowledge receipt

**Signature Validation:**

```
signature = Base64(HMAC-SHA256(channel_secret, request_body))
```

---

### POST /line/push

Push a message to a LINE user or group.

**Request:**

```json
{
  "to": "U1234567890",
  "msg": "Hello from Gokabot!"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| to | string | Yes | LINE user ID or group ID |
| msg | string | Yes | Message to send |

**Response:**

```json
{
  "status": 200
}
```

**Status Codes:**

- `200 OK` - Message sent successfully
- `400 Bad Request` - Invalid request
- `401 Unauthorized` - Invalid LINE token
- `500 Internal Server Error` - Failed to send

---

### POST /discord/push

Push a message to a Discord channel.

**Request:**

```json
{
  "target_id": "123456789012345678",
  "msg": "Hello from Gokabot!"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| target_id | string | Yes | Discord channel ID |
| msg | string | Yes | Message to send |

**Response:**

```json
{
  "status": 200
}
```

**Status Codes:**

- `200 OK` - Message sent successfully
- `400 Bad Request` - Invalid request
- `403 Forbidden` - Bot lacks permission
- `404 Not Found` - Channel not found
- `500 Internal Server Error` - Failed to send

---

## Answerers

Messages are processed by a chain of answerers in priority order. The first answerer to return a non-nil response wins.

| Priority | Name | Trigger Pattern | Description |
|----------|------|-----------------|-------------|
| 1 | Nyokki | `/(1\|１)(にょっき\|ニョッキ\|ﾆｮｯｷ)/` | Counting game |
| 2 | Gokabou | Various patterns | Greetings, omikuji, help, Markov text |
| 3 | Anime | `アニメ`, `今期`, `来期`, weekday names | Anime schedule lookup |
| 4 | Weather | `天気`, `今日の天気`, `明日の天気` | Weather information |
| 5 | WebDict | `〜って?`, `〜とは`, `〜何?` | Dictionary lookup (Wikipedia, Niconico, Pixiv) |
| 6 | Denippi | Single hiragana/katakana, `寝`, `うん` | Word chain game |
| 7 | Tex | `$...$` (LaTeX) | LaTeX rendering via Google Charts |
| 8 | Pigeons | `鳩`, `ゆかり`, `はと` | Random email from CSV |
| 9 | DflSearch | `doll <name>`, `doll damage <name>` | Doll image lookup |
| 10 | BaseballNews | `野球`, `野球速報` | NPB game results |

---

## Database Schema

### gokabot.animes

| Column | Type | Description |
|--------|------|-------------|
| year | integer | Year (e.g., 2024) |
| season | string | Season: winter, spring, summer, fall |
| day | string | Day of week |
| time | string | Broadcast time |
| title | string | Anime title |
| station | string | TV station |
| recommend | boolean | Recommended flag |

### gokabot.cities

| Column | Type | Description |
|--------|------|-------------|
| id | integer | OpenWeatherMap city ID |
| name | string | City name (English) |
| jp_name | string | City name (Japanese) |

### gokabot.gokabous

| Column | Type | Description |
|--------|------|-------------|
| sentence | string | Training sentence for Markov chain |
| reg_date | string | Registration date |

---

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| DATABASE_URL | Yes | PostgreSQL connection string |
| LINE_CHANNEL_SECRET | Yes | LINE channel secret for signature validation |
| LINE_CHANNEL_TOKEN | Yes | LINE channel access token |
| DISCORD_BOT_TOKEN | Yes | Discord bot token |
| DISCORD_TARGET_CHANNEL_ID | No | Default Discord channel ID |
| OPEN_WEATHER_API_KEY | Yes | OpenWeatherMap API key |
| GOKABOU_USER_ID | No | Special user ID for Gokabou features |

---

## Response Limits

- Maximum response length: **2000 characters** (LINE limit)
- Responses exceeding this limit are truncated

---

## Error Handling

When an answerer throws an exception, the API returns:

```json
{
  "type": "text",
  "text": "エラーおつｗｗｗｗｗｗ\n\n> {error_message}"
}
```
