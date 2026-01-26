# LINE webhook signature validation tests
#
# These tests verify that the LINE webhook endpoint properly validates
# the X-Line-Signature header using HMAC-SHA256.
#
# Test channel secret: test_channel_secret
# Signature is calculated as: Base64(HMAC-SHA256(channel_secret, body))

# =============================================================================
# Valid signature - should return 200
# =============================================================================
# Body: {"events":[]}
# Signature: echo -n '{"events":[]}' | openssl dgst -sha256 -hmac 'test_channel_secret' -binary | base64

POST {{host}}/line/callback
Content-Type: application/json
X-Line-Signature: mDDIqkhmFK977Aoz/X61Z+SomnHnv9VmI2xzNyoGoXc=
{"events":[]}
HTTP 200

# =============================================================================
# Invalid signature - should return 400
# =============================================================================

POST {{host}}/line/callback
Content-Type: application/json
X-Line-Signature: invalid_signature
{"events":[]}
HTTP 400

# =============================================================================
# Missing signature header - should return 400
# =============================================================================

POST {{host}}/line/callback
Content-Type: application/json
{"events":[]}
HTTP 400

# =============================================================================
# Valid signature with message event - should return 200
# =============================================================================
# Body for this test (formatted for readability, actual body is minified):
# {
#   "events": [{
#     "type": "message",
#     "replyToken": "test_reply_token",
#     "source": {"type": "user", "userId": "U1234567890"},
#     "message": {"type": "text", "id": "12345", "text": "hello"}
#   }]
# }

POST {{host}}/line/callback
Content-Type: application/json
X-Line-Signature: +vz7xFDOxxjt6YWTGOMHl7K30t4FT5nKpUSUKzjZSWY=
{"events":[{"type":"message","replyToken":"test_reply_token","source":{"type":"user","userId":"U1234567890"},"message":{"type":"text","id":"12345","text":"hello"}}]}
HTTP 200
