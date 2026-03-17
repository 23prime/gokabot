package handler

import (
	"database/sql"
	"encoding/json"
	"log/slog"
	"net/http"
)

type HealthResponse struct {
	Healthy bool `json:"healthy"`
	DB      bool `json:"db"`
}

func HealthCheck(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")

		resp := HealthResponse{Healthy: true, DB: true}

		ctx := r.Context()

		if err := db.PingContext(ctx); err != nil {
			slog.ErrorContext(ctx, "Database is unhealthy", "error", err)
			resp.Healthy = false
			resp.DB = false
			w.WriteHeader(http.StatusInternalServerError)
			if err := json.NewEncoder(w).Encode(resp); err != nil {
				slog.ErrorContext(ctx, "Failed to encode health status", "error", err)
			}
			return
		}

		slog.DebugContext(ctx, "Database is healthy")

		if err := json.NewEncoder(w).Encode(resp); err != nil {
			slog.ErrorContext(ctx, "Failed to encode health status", "error", err)
		}
	}
}
