package handler

import (
	"log/slog"
	"net/http"

	"github.com/23prime/gokabot-api/internal/line"
	"github.com/line/line-bot-sdk-go/v8/linebot/webhook"
)

func LineCallback(channelSecret string, lineClient line.Client) http.HandlerFunc {
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

		for _, event := range cb.Events {
			e, ok := event.(webhook.MessageEvent)
			if !ok {
				continue
			}

			msg, ok := e.Message.(webhook.TextMessageContent)
			if !ok {
				continue
			}

			if lineClient == nil {
				slog.WarnContext(ctx, "LINE client not initialized, skipping reply")
				continue
			}

			if err := lineClient.ReplyText(ctx, e.ReplyToken, msg.Text); err != nil {
				slog.WarnContext(ctx, "Failed to reply", "error", err)
			}
		}

		w.WriteHeader(http.StatusOK)
	}
}
