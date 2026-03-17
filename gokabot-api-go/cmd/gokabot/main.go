package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"time"

	"github.com/23prime/gokabot-api/internal/answerer"
	"github.com/23prime/gokabot-api/internal/answerers/anime"
	"github.com/23prime/gokabot-api/internal/answerers/baseballnews"
	"github.com/23prime/gokabot-api/internal/answerers/denippi"
	"github.com/23prime/gokabot-api/internal/answerers/nyokki"
	"github.com/23prime/gokabot-api/internal/answerers/pigeons"
	"github.com/23prime/gokabot-api/internal/answerers/tex"
	"github.com/23prime/gokabot-api/internal/answerers/weather"
	"github.com/23prime/gokabot-api/internal/answerers/webdict"
	"github.com/23prime/gokabot-api/internal/config"
	"github.com/23prime/gokabot-api/internal/database"
	"github.com/23prime/gokabot-api/internal/handler"
	"github.com/23prime/gokabot-api/internal/line"
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
	defer func() {
		if err := db.Close(); err != nil {
			slog.Error("Failed to close database", "error", err)
		}
	}()
	slog.Info("Connected to database")

	// Initialize LINE client
	lineClient, err := line.New(cfg.LineChannelSecret, cfg.LineChannelToken)
	if err != nil {
		slog.Error("Failed to initialize LINE client", "error", err)
		os.Exit(1)
	}

	// Set up answerer chain
	registry := answerer.NewRegistry(
		nyokki.New(),
		anime.New(db),
		weather.New(db, cfg.OpenWeatherAPIKey),
		webdict.New(),
		denippi.New(),
		tex.New(),
		baseballnews.New(),
		pigeons.New(db),
	)

	// Set up HTTP handlers
	http.HandleFunc("/healthCheck", handler.RequestLog(handler.HealthCheck(db)))
	http.HandleFunc("/line/callback", handler.RequestLog(handler.LineCallback(cfg.LineChannelSecret, lineClient, registry)))
	http.HandleFunc("/line/push", handler.RequestLog(handler.LinePush(lineClient)))

	slog.Info("Gokabot API started", "port", cfg.Port)

	// Start the HTTP server
	srv := &http.Server{
		Addr:         fmt.Sprintf(":%d", cfg.Port),
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  120 * time.Second,
	}
	if err := srv.ListenAndServe(); err != nil {
		slog.Error("Failed to start server", "error", err)
	}
}
