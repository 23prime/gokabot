package handler

import (
	"database/sql"
	"encoding/json"
	"log/slog"
	"net/http"
)

type Response struct {
	Healthy bool `json:"healthy"`
	DB      bool `json:"db"`
}

func HealthCheck(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")

		resp := Response{Healthy: true, DB: true}

		if err := db.PingContext(r.Context()); err != nil {
			slog.Error("Database is unhealthy", "error", err)
			resp.Healthy = false
			resp.DB = false
			w.WriteHeader(http.StatusInternalServerError)
		} else {
			slog.Info("Database is healthy")
		}

		if err := json.NewEncoder(w).Encode(resp); err != nil {
			slog.Error("Failed to encode health status", "error", err)
		}
	}
}
