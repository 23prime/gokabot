package logger

import (
	"context"
	"io"
	"log/slog"
)

type emojiHandler struct {
	slog.Handler
}

func (h *emojiHandler) Handle(ctx context.Context, r slog.Record) error {
	var prefix string
	switch {
	case r.Level >= slog.LevelError:
		prefix = "🔥 "
	case r.Level >= slog.LevelWarn:
		prefix = "⚠️ "
	case r.Level >= slog.LevelInfo:
		prefix = "💡 "
	default: // Debug
		prefix = "🔍 "
	}
	r.Message = prefix + r.Message
	return h.Handler.Handle(ctx, r)
}

func NewEmojiLogger(w io.Writer, level slog.Level) *slog.Logger {
	return slog.New(&emojiHandler{
		Handler: slog.NewJSONHandler(w, &slog.HandlerOptions{
			Level: level,
		}),
	})
}
