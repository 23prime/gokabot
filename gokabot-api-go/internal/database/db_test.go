package database_test

import (
	"testing"

	"github.com/23prime/gokabot-api/internal/database"
)

func TestConnect_InvalidURL(t *testing.T) {
	_, err := database.Connect("postgres://invalid:5432/nonexistent?connect_timeout=1")
	if err == nil {
		t.Error("got nil, want error for invalid database URL")
	}
}
