package config

import (
	"fmt"
	"log/slog"
	"os"
	"strings"
)

type Config struct {
	DBURL    string
	LogLevel slog.Level
}

func Load() (*Config, error) {
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		return nil, fmt.Errorf("DATABASE_URL must be set")
	}

	logLevel := parseLogLevel(os.Getenv("LOG_LEVEL"))

	cfg := &Config{
		DBURL:    dbURL,
		LogLevel: logLevel,
	}
	return cfg, nil
}

func parseLogLevel(s string) slog.Level {
	switch strings.ToLower(s) {
	case "debug":
		return slog.LevelDebug
	case "warn", "warning":
		return slog.LevelWarn
	case "error":
		return slog.LevelError
	default:
		return slog.LevelInfo
	}
}
