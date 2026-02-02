package handler

import (
	"log/slog"
	"net/http"

	"github.com/line/line-bot-sdk-go/v8/linebot/webhook"
)

func LineCallback(channelSecret string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()

		if r.Method != http.MethodPost {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}

		cb, err := webhook.ParseRequest(channelSecret, r)
		if err != nil {
			slog.WarnContext(ctx, "Failed to parse LINE webhook request", "error", err)
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		slog.InfoContext(ctx, "LINE callback received", "events", len(cb.Events))
		w.WriteHeader(http.StatusOK)
	}
}
