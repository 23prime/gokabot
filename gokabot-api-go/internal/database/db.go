package database

import (
	"database/sql"
	"errors"
	"time"

	_ "github.com/lib/pq"
)

func Connect(dbURL string) (*sql.DB, error) {
	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		return nil, err
	}

	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(5 * time.Minute)

	if pingErr := db.Ping(); pingErr != nil {
		if closeErr := db.Close(); closeErr != nil {
			return nil, errors.Join(pingErr, closeErr)
		}
		return nil, pingErr
	}

	return db, nil
}
