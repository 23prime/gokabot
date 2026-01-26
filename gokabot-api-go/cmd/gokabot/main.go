package main

import (
	"log/slog"
	"os"

	"github.com/23prime/gokabot-api/internal/config"
	"github.com/23prime/gokabot-api/internal/logger"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		slog.Error("Failed to load config", "error", err)
		os.Exit(1)
	}

	slog.SetDefault(logger.NewEmojiLogger(os.Stdout, cfg.LogLevel))

	slog.Debug("Config loaded")
	slog.Info("Gokabot API started")
}
