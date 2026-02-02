package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"

	"github.com/23prime/gokabot-api/internal/config"
	"github.com/23prime/gokabot-api/internal/database"
	"github.com/23prime/gokabot-api/internal/handler"
	"github.com/23prime/gokabot-api/internal/logger"
)

func main() {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		slog.Error("Failed to load config", "error", err)
		os.Exit(1)
	}
	slog.SetDefault(logger.NewEmojiLogger(os.Stdout, cfg.LogLevel))

	// Connect to the database
	db, err := database.Connect(cfg.DBURL)
	if err != nil {
		slog.Error("Failed to connect to database", "error", err)
		os.Exit(1)
	}
	defer db.Close()
	slog.Info("Connected to database")

	// Set up HTTP handlers
	http.HandleFunc("/healthCheck", handler.RequestLog(handler.HealthCheck(db)))
	http.HandleFunc("/line/callback", handler.RequestLog(handler.LineCallback(cfg.LineChannelSecret)))

	slog.Info("Gokabot API started", "port", cfg.Port)

	// Start the HTTP server
	slog.Error(
		"Failed to start server",
		"error",
		http.ListenAndServe(fmt.Sprintf(":%d", cfg.Port), nil),
	)
}
