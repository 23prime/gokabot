package handler

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHealthCheck(t *testing.T) {
	tests := []struct {
		name           string
		wantStatusCode int
		wantHealthy    bool
	}{
		{
			name:           "returns healthy status",
			wantStatusCode: http.StatusOK,
			wantHealthy:    true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest(http.MethodGet, "/healthCheck", nil)
			rec := httptest.NewRecorder()

			HealthCheck(rec, req)

			if rec.Code != tt.wantStatusCode {
				t.Errorf("status code = %d, want %d", rec.Code, tt.wantStatusCode)
			}

			contentType := rec.Header().Get("Content-Type")
			if contentType != "application/json" {
				t.Errorf("Content-Type = %q, want %q", contentType, "application/json")
			}

			var got Response
			if err := json.NewDecoder(rec.Body).Decode(&got); err != nil {
				t.Fatalf("failed to decode response: %v", err)
			}

			if got.Healthy != tt.wantHealthy {
				t.Errorf("Healthy = %v, want %v", got.Healthy, tt.wantHealthy)
			}
		})
	}
}
