package config

import (
	"fmt"
	"os"
)

type Config struct {
	DBURL string
}

func Load() (*Config, error) {
	DBURL := os.Getenv("DATABASE_URL")
	if DBURL == "" {
		return nil, fmt.Errorf("DATABASE_URL must be set")
	}

	cfg := &Config{
		DBURL: DBURL,
	}
	return cfg, nil
}
