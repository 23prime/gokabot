package handler

import (
	"log/slog"
	"net/http"

	"github.com/23prime/gokabot-api/internal/answerer"
	"github.com/23prime/gokabot-api/internal/line"
	"github.com/line/line-bot-sdk-go/v8/linebot/webhook"
)

func LineCallback(channelSecret string, lineClient line.Client, registry *answerer.Registry) http.HandlerFunc {
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

			data := answerer.MessageData{
				Message: msg.Text,
				UserID:  userIDFromSource(e.Source),
			}

			resp := registry.Dispatch(data)
			if resp == nil {
				continue
			}

			if lineClient == nil {
				slog.WarnContext(ctx, "LINE client not initialized, skipping reply")
				continue
			}

			if err := lineClient.ReplyText(ctx, e.ReplyToken, resp.Text); err != nil {
				slog.WarnContext(ctx, "Failed to reply", "error", err)
			}
		}

		w.WriteHeader(http.StatusOK)
	}
}

func userIDFromSource(source webhook.SourceInterface) string {
	switch s := source.(type) {
	case webhook.UserSource:
		return s.UserId
	case webhook.GroupSource:
		return s.UserId
	case webhook.RoomSource:
		return s.UserId
	default:
		return ""
	}
}
