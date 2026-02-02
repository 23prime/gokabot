package handler

import (
	"log/slog"
	"net/http"
	"time"

	"github.com/google/uuid"

	"github.com/23prime/gokabot-api/internal/logger"
)

var _ http.ResponseWriter = (*responseWriter)(nil)

type responseWriter struct {
	http.ResponseWriter
	statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}

func RequestLog(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rw := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}

		requestID := uuid.New().String()
		ctx := logger.WithRequestID(r.Context(), requestID)
		r = r.WithContext(ctx)

		slog.InfoContext(ctx, "Request started",
			"method", r.Method,
			"path", r.URL.Path,
		)

		next(rw, r)

		slog.InfoContext(ctx, "Request completed",
			"method", r.Method,
			"path", r.URL.Path,
			"status", rw.statusCode,
			"duration", time.Since(start),
		)
	}
}
