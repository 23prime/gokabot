package config

import (
	"log/slog"
	"testing"
)

func TestLoad_Success(t *testing.T) {
	t.Setenv("DATABASE_URL", "postgres://localhost/test")
	t.Setenv("LOG_LEVEL", "DEBUG")
	t.Setenv("PORT", "8081")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("Load() error = %v, want nil", err)
	}

	if cfg.DBURL != "postgres://localhost/test" {
		t.Errorf("DBURL = %q, want %q", cfg.DBURL, "postgres://localhost/test")
	}
	if cfg.LogLevel != slog.LevelDebug {
		t.Errorf("LogLevel = %v, want %v", cfg.LogLevel, slog.LevelDebug)
	}
	if cfg.Port != 8081 {
		t.Errorf("Port = %d, want %d", cfg.Port, 8081)
	}
}

func TestLoad_ErrorWhenDatabaseURLNotSet(t *testing.T) {
	t.Setenv("DATABASE_URL", "")
	t.Setenv("LOG_LEVEL", "DEBUG")
	t.Setenv("PORT", "8081")

	_, err := Load()
	if err == nil {
		t.Fatalf("Load() error = nil, want error")
	}
}

func TestLoad_Default(t *testing.T) {
	t.Setenv("DATABASE_URL", "postgres://localhost/test")
	t.Setenv("LOG_LEVEL", "")
	t.Setenv("PORT", "")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("Load() error = %v, want nil", err)
	}

	if cfg.LogLevel != defaultLogLevel {
		t.Errorf("LogLevel = %v, want %v", cfg.LogLevel, defaultLogLevel)
	}

	if cfg.Port != defaultPort {
		t.Errorf("Port = %d, want %d", cfg.Port, defaultPort)
	}
}
