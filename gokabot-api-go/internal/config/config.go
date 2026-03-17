package config

import (
	"fmt"
	"log/slog"
	"os"
	"strconv"
	"strings"
)

type Config struct {
	DBURL             string
	LineChannelSecret string
	LineChannelToken  string
	OpenWeatherAPIKey string
	LogLevel          slog.Level
	Port              int
}

const (
	defaultLogLevel = slog.LevelInfo
	defaultPort     = 8080
)

func Load() (*Config, error) {
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		return nil, fmt.Errorf("DATABASE_URL must be set")
	}

	lineChannelSecret := os.Getenv("LINE_CHANNEL_SECRET")
	if lineChannelSecret == "" {
		return nil, fmt.Errorf("LINE_CHANNEL_SECRET must be set")
	}

	lineChannelToken := os.Getenv("LINE_CHANNEL_TOKEN")
	if lineChannelToken == "" {
		return nil, fmt.Errorf("LINE_CHANNEL_TOKEN must be set")
	}

	logLevel := parseLogLevel(os.Getenv("LOG_LEVEL"))

	cfg := &Config{
		DBURL:             dbURL,
		LineChannelSecret: lineChannelSecret,
		LineChannelToken:  lineChannelToken,
		OpenWeatherAPIKey: os.Getenv("OPEN_WEATHER_API_KEY"),
		LogLevel:          logLevel,
		Port:              parsePort(os.Getenv("PORT")),
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
		return defaultLogLevel
	}
}

func parsePort(s string) int {
	if s == "" {
		return defaultPort
	}

	port, err := strconv.Atoi(s)
	if err != nil {
		return defaultPort
	}

	return port
}
