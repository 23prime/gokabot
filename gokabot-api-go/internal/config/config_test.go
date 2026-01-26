package config

import (
	"log/slog"
	"testing"
)

func TestLoad_Success(t *testing.T) {
	t.Setenv("DATABASE_URL", "postgres://localhost/test")
	t.Setenv("LOG_LEVEL", "DEBUG")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if cfg.DBURL != "postgres://localhost/test" {
		t.Errorf("Expected DBURL to be 'postgres://localhost/test', got %s", cfg.DBURL)
	}
	if cfg.LogLevel != slog.LevelDebug {
		t.Errorf("Expected LogLevel to be 'DEBUG', got %v", cfg.LogLevel)
	}
}

func TestLoad_ErrorWhenDatabaseURLNotSet(t *testing.T) {
	t.Setenv("DATABASE_URL", "")
	t.Setenv("LOG_LEVEL", "DEBUG")

	_, err := Load()
	if err == nil {
		t.Fatalf("Expected error, got nil")
	}
}

func TestLoad_DefaultLogLevel(t *testing.T) {
	t.Setenv("DATABASE_URL", "postgres://localhost/test")
	t.Setenv("LOG_LEVEL", "")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if cfg.LogLevel != slog.LevelInfo {
		t.Errorf("Expected default LogLevel to be 'INFO', got %v", cfg.LogLevel)
	}
}
