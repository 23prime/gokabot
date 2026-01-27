package handler

import (
	"encoding/json"
	"log/slog"
	"net/http"
)

type Response struct {
	Healthy bool `json:"healthy"`
}

func HealthCheck(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(Response{Healthy: true}); err != nil {
		slog.Error("Failed to encode health status", "error", err)
	}
}
