package handler

import (
	"encoding/json"
	"log/slog"
	"net/http"

	"github.com/23prime/gokabot-api/internal/line"
)

type PushRequest struct {
	TargetID string `json:"target_id"`
	Msg      string `json:"msg"`
}

func LinePush(lineClient line.Client) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()

		if r.Method != http.MethodPost {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}

		var req PushRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			slog.WarnContext(ctx, "Failed to decode push request", "error", err)
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		if req.TargetID == "" || req.Msg == "" {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		if lineClient == nil {
			slog.WarnContext(ctx, "LINE client not initialized, skipping push")
			w.WriteHeader(http.StatusOK)
			return
		}

		if err := lineClient.PushText(ctx, req.TargetID, req.Msg); err != nil {
			slog.WarnContext(ctx, "Failed to push message", "error", err)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
	}
}
