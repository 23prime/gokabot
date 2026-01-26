package config

import "testing"

func TestLoad_Success(t *testing.T) {
	t.Setenv("DATABASE_URL", "postgres://localhost/test")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if cfg.DBURL != "postgres://localhost/test" {
		t.Errorf("Expected DBURL to be 'postgres://localhost/test', got %s", cfg.DBURL)
	}
}

func TestLoad_ErrorWhenDatabaseURLNotSet(t *testing.T) {
	t.Setenv("DATABASE_URL", "")

	_, err := Load()
	if err == nil {
		t.Fatalf("Expected error, got nil")
	}
}
