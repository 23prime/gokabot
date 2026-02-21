package handler

import (
	"bytes"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestLinePush(t *testing.T) {
	mock := &mockLineClient{}
	h := LinePush(mock)

	tests := []struct {
		name       string
		method     string
		body       string
		wantStatus int
		wantTo     string
		wantText   string
	}{
		{
			name:       "valid request",
			method:     http.MethodPost,
			body:       `{"target_id":"U123","msg":"hello"}`,
			wantStatus: http.StatusOK,
			wantTo:     "U123",
			wantText:   "hello",
		},
		{
			name:       "missing target_id",
			method:     http.MethodPost,
			body:       `{"target_id":"","msg":"hello"}`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name:       "missing msg",
			method:     http.MethodPost,
			body:       `{"target_id":"U123","msg":""}`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name:       "invalid json",
			method:     http.MethodPost,
			body:       `not-json`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name:       "wrong method",
			method:     http.MethodGet,
			body:       "",
			wantStatus: http.StatusMethodNotAllowed,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mock.pushTo = ""
			mock.pushText = ""

			req := httptest.NewRequest(tt.method, "/line/push", bytes.NewBufferString(tt.body))
			rec := httptest.NewRecorder()

			h(rec, req)

			if got := rec.Code; got != tt.wantStatus {
				t.Errorf("status got %d, want %d", got, tt.wantStatus)
			}
			if tt.wantTo != "" && mock.pushTo != tt.wantTo {
				t.Errorf("pushTo got %q, want %q", mock.pushTo, tt.wantTo)
			}
			if tt.wantText != "" && mock.pushText != tt.wantText {
				t.Errorf("pushText got %q, want %q", mock.pushText, tt.wantText)
			}
		})
	}
}

func TestLinePush_NilClient(t *testing.T) {
	h := LinePush(nil)

	req := httptest.NewRequest(http.MethodPost, "/line/push", bytes.NewBufferString(`{"target_id":"U123","msg":"hello"}`))
	rec := httptest.NewRecorder()

	h(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("status got %d, want %d", rec.Code, http.StatusOK)
	}
}
