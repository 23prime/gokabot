package logger

import (
	"bytes"
	"context"
	"log/slog"
	"strings"
	"testing"
)

func TestNewEmojiLogger(t *testing.T) {
	tests := []struct {
		name      string
		level     slog.Level
		message   string
		wantEmoji string
	}{
		{"debug", slog.LevelDebug, "debug message", "🔍 "},
		{"info", slog.LevelInfo, "info message", "💡 "},
		{"warn", slog.LevelWarn, "warn message", "⚠️ "},
		{"error", slog.LevelError, "error message", "🔥 "},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var buf bytes.Buffer
			logger := NewEmojiLogger(&buf, slog.LevelDebug)

			logger.Log(context.Background(), tt.level, tt.message)

			output := buf.String()
			wantMsg := tt.wantEmoji + tt.message
			if !strings.Contains(output, wantMsg) {
				t.Errorf("output %q does not contain %q", output, wantMsg)
			}
		})
	}
}
