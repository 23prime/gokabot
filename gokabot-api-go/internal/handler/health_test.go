package handler

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
)

func TestHealthCheck(t *testing.T) {
	tests := []struct {
		name           string
		dbHealthy      bool
		wantStatusCode int
		wantHealthy    bool
		wantDB         bool
	}{
		{
			name:           "returns healthy when DB is reachable",
			dbHealthy:      true,
			wantStatusCode: http.StatusOK,
			wantHealthy:    true,
			wantDB:         true,
		},
		{
			name:           "returns unhealthy when DB is unreachable",
			dbHealthy:      false,
			wantStatusCode: http.StatusInternalServerError,
			wantHealthy:    false,
			wantDB:         false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			db, mock, err := sqlmock.New(sqlmock.MonitorPingsOption(true))
			if err != nil {
				t.Fatalf("failed to create sqlmock: %v", err)
			}
			defer db.Close()

			if tt.dbHealthy {
				mock.ExpectPing()
			} else {
				mock.ExpectPing().WillReturnError(http.ErrServerClosed)
			}

			req := httptest.NewRequest(http.MethodGet, "/healthCheck", nil)
			rec := httptest.NewRecorder()

			HealthCheck(db).ServeHTTP(rec, req)

			if rec.Code != tt.wantStatusCode {
				t.Errorf("status code = %d, want %d", rec.Code, tt.wantStatusCode)
			}

			contentType := rec.Header().Get("Content-Type")
			if contentType != "application/json" {
				t.Errorf("Content-Type = %q, want %q", contentType, "application/json")
			}

			var got HealthResponse
			if err := json.NewDecoder(rec.Body).Decode(&got); err != nil {
				t.Fatalf("failed to decode response: %v", err)
			}

			if got.Healthy != tt.wantHealthy {
				t.Errorf("Healthy = %v, want %v", got.Healthy, tt.wantHealthy)
			}

			if got.DB != tt.wantDB {
				t.Errorf("DB = %v, want %v", got.DB, tt.wantDB)
			}
		})
	}
}
