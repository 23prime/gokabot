package main

import (
	"fmt"

	"github.com/23prime/gokabot-api/internal/config"
)

func main() {
	fmt.Println("Reading...")

	config, err := config.Load()

	if err != nil {
		fmt.Println("Error loading config:", err)
		return
	}

	// For debug
	fmt.Println("Database URL:", config.DBURL)

	fmt.Println("🚀 Gokabot API started successfully")
}
