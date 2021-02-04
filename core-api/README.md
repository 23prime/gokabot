# Gokabot / core-api

The core Web API of Gokabot.

## APIs

### `/callback`

#### `POST`

- body:

```json
{
    "msg": "<your message>",
    "user_id": "<your ID>",
    "user_name": "<your name>"
}
```

### `/line/push`

- body:

```json
{
    "message": "<your message>",
    "target_id": "<The LINE ID of user or group you want to a message to>"
}
```

### `/line/push/random`

- body:

```json
{
    "target_id": "<The LINE ID of user or group you want to a message to>"
}
```

### `/discord/push`

- body:

```json
{
    "message": "<your message>",
    "target_id": "<The Discord channel ID you want to send a message to>"
}
```

### `/discord/push/random`

- body:

```json
{
    "target_id": "<The Discord channel ID you want to send a message to>"
}
```
