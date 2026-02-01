package handler

import (
	"bytes"
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

func TestLineCallback(t *testing.T) {
	secret := "test-channel-secret"
	h := LineCallback(secret)

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
