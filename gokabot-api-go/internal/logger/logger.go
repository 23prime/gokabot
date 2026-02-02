package logger

import (
	"context"
	"io"
	"log/slog"
)

type contextKey string

const requestIDKey contextKey = "request_id"

// WithRequestID returns a new context with the given request ID.
func WithRequestID(ctx context.Context, id string) context.Context {
	return context.WithValue(ctx, requestIDKey, id)
}

// RequestIDFromContext extracts the request ID from context.
func RequestIDFromContext(ctx context.Context) string {
	if id, ok := ctx.Value(requestIDKey).(string); ok {
		return id
	}
	return ""
}

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

	if id := RequestIDFromContext(ctx); id != "" {
		r.AddAttrs(slog.String("request_id", id))
	}

	return h.Handler.Handle(ctx, r)
}

func NewEmojiLogger(w io.Writer, level slog.Level) *slog.Logger {
	return slog.New(&emojiHandler{
		Handler: slog.NewJSONHandler(w, &slog.HandlerOptions{
			Level: level,
		}),
	})
}
