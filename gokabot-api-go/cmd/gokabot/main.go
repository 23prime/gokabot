package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"

	"github.com/23prime/gokabot-api/internal/config"
	"github.com/23prime/gokabot-api/internal/handler"
	"github.com/23prime/gokabot-api/internal/logger"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		slog.Error("Failed to load config", "error", err)
		os.Exit(1)
	}
	slog.SetDefault(logger.NewEmojiLogger(os.Stdout, cfg.LogLevel))

	http.HandleFunc("/healthCheck", handler.RequestLog(handler.HealthCheck))

	slog.Info(fmt.Sprintf("Gokabot API started on port %d", cfg.Port))

	slog.Error(
		"Failed to start server",
		"error",
		http.ListenAndServe(fmt.Sprintf(":%d", cfg.Port), nil),
	)
}
