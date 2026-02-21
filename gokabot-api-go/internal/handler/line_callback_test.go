package handler

import (
	"bytes"
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"net/http"
	"net/http/httptest"
	"testing"
)

func signBody(body []byte, secret string) string {
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write(body)
	return base64.StdEncoding.EncodeToString(mac.Sum(nil))
}

// mockLineClient records ReplyText calls.
type mockLineClient struct {
	replyToken string
	replyText  string
	pushTo     string
	pushText   string
}

func (m *mockLineClient) ReplyText(ctx context.Context, replyToken, text string) error {
	_ = ctx
	m.replyToken = replyToken
	m.replyText = text
	return nil
}

func (m *mockLineClient) PushText(ctx context.Context, to, text string) error {
	_ = ctx
	m.pushTo = to
	m.pushText = text
	return nil
}

func TestLineCallback(t *testing.T) {
	secret := "test-channel-secret"
	mock := &mockLineClient{}
	h := LineCallback(secret, mock)

	validBody := []byte(`{"events":[]}`)

	tests := []struct {
		name       string
		method     string
		body       []byte
		signature  string
		wantStatus int
	}{
		{
			name:       "valid request",
			method:     http.MethodPost,
			body:       validBody,
			signature:  signBody(validBody, secret),
			wantStatus: http.StatusOK,
		},
		{
			name:       "missing signature",
			method:     http.MethodPost,
			body:       validBody,
			signature:  "",
			wantStatus: http.StatusBadRequest,
		},
		{
			name:       "invalid signature",
			method:     http.MethodPost,
			body:       validBody,
			signature:  "invalid",
			wantStatus: http.StatusBadRequest,
		},
		{
			name:       "wrong method",
			method:     http.MethodGet,
			body:       nil,
			signature:  "",
			wantStatus: http.StatusMethodNotAllowed,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest(tt.method, "/line/callback", bytes.NewReader(tt.body))
			if tt.signature != "" {
				req.Header.Set("X-Line-Signature", tt.signature)
			}
			rec := httptest.NewRecorder()

			h(rec, req)

			if got := rec.Code; got != tt.wantStatus {
				t.Errorf("status got %d, want %d", got, tt.wantStatus)
			}
		})
	}
}

func TestLineCallback_EchoReply(t *testing.T) {
	secret := "test-channel-secret"
	mock := &mockLineClient{}
	h := LineCallback(secret, mock)

	body := []byte(`{
		"events": [{
			"type": "message",
			"replyToken": "reply-token-123",
			"source": {"type": "user", "userId": "U123"},
			"timestamp": 1704067200000,
			"mode": "active",
			"message": {
				"type": "text",
				"id": "msg-1",
				"text": "hello"
			}
		}]
	}`)

	req := httptest.NewRequest(http.MethodPost, "/line/callback", bytes.NewReader(body))
	req.Header.Set("X-Line-Signature", signBody(body, secret))
	rec := httptest.NewRecorder()

	h(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("status got %d, want %d", rec.Code, http.StatusOK)
	}
	if mock.replyToken != "reply-token-123" {
		t.Errorf("replyToken got %q, want %q", mock.replyToken, "reply-token-123")
	}
	if mock.replyText != "hello" {
		t.Errorf("replyText got %q, want %q", mock.replyText, "hello")
	}
}

func TestLineCallback_NilClient(t *testing.T) {
	secret := "test-channel-secret"
	h := LineCallback(secret, nil)

	body := []byte(`{
		"events": [{
			"type": "message",
			"replyToken": "reply-token-123",
			"source": {"type": "user", "userId": "U123"},
			"timestamp": 1704067200000,
			"mode": "active",
			"message": {
				"type": "text",
				"id": "msg-1",
				"text": "hello"
			}
		}]
	}`)

	req := httptest.NewRequest(http.MethodPost, "/line/callback", bytes.NewReader(body))
	req.Header.Set("X-Line-Signature", signBody(body, secret))
	rec := httptest.NewRecorder()

	h(rec, req)

	// Should still return 200, just skip the reply
	if rec.Code != http.StatusOK {
		t.Errorf("status got %d, want %d", rec.Code, http.StatusOK)
	}
}
