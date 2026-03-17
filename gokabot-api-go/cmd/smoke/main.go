// smoke is a manual smoke-test runner that exercises each answerer against
// real external services (npb.jp, OpenWeatherMap, web dictionaries) and a
// live database.
//
// Usage:
//
//	mise dc-up-db-d          # start PostgreSQL
//	mise go-smoke            # run smoke tests
//
// Required environment variables (loaded automatically via mise):
//
//	DATABASE_URL             - PostgreSQL connection string
//
// Optional environment variables (set in .env):
//
//	OPEN_WEATHER_API_KEY     - enables real weather responses (skips gracefully if absent)
package main

import (
	"fmt"
	"log/slog"
	"os"

	"github.com/23prime/gokabot-api/internal/answerer"
	"github.com/23prime/gokabot-api/internal/answerers/anime"
	"github.com/23prime/gokabot-api/internal/answerers/baseballnews"
	"github.com/23prime/gokabot-api/internal/answerers/denippi"
	"github.com/23prime/gokabot-api/internal/answerers/gokabou"
	"github.com/23prime/gokabot-api/internal/answerers/nyokki"
	"github.com/23prime/gokabot-api/internal/answerers/pigeons"
	"github.com/23prime/gokabot-api/internal/answerers/searchdolls"
	"github.com/23prime/gokabot-api/internal/answerers/tex"
	"github.com/23prime/gokabot-api/internal/answerers/weather"
	"github.com/23prime/gokabot-api/internal/answerers/webdict"
	"github.com/23prime/gokabot-api/internal/database"
	"github.com/23prime/gokabot-api/internal/logger"
)

type suite struct {
	name     string
	a        answerer.Answerer
	messages []string
}

func main() {
	slog.SetDefault(logger.NewEmojiLogger(os.Stdout, slog.LevelWarn))

	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		fmt.Fprintln(os.Stderr, "ERROR: DATABASE_URL is not set")
		os.Exit(1)
	}

	db, err := database.Connect(dbURL)
	if err != nil {
		fmt.Fprintf(os.Stderr, "ERROR: failed to connect to database: %v\n", err)
		os.Exit(1)
	}
	defer db.Close() //nolint:errcheck

	owKey := os.Getenv("OPEN_WEATHER_API_KEY")

	suites := []suite{
		{
			name:     "nyokki",
			a:        nyokki.New(),
			messages: []string{"1にょっき", "2にょっき", "にょっき"},
		},
		{
			name:     "gokabou",
			a:        gokabou.New(db),
			messages: []string{"こん", "ぬるぽ", "おみくじ", "ごかぼう", "ヒゲ", "死ね"},
		},
		{
			name:     "anime",
			a:        anime.New(db),
			messages: []string{"アニメ", "アニメ おすすめ", "mon", "月", "今日"},
		},
		{
			name:     "weather",
			a:        weather.New(db, owKey),
			messages: []string{"天気", "今日の天気", "明日の天気", "天気 大阪"},
		},
		{
			name:     "webdict",
			a:        webdict.New(),
			messages: []string{"猫とは", "ゴジラとは", "Claude って？"},
		},
		{
			name:     "denippi",
			a:        denippi.New(),
			messages: []string{"ね", "あ", "あ", "うん"},
		},
		{
			name:     "tex",
			a:        tex.New(),
			messages: []string{"$x^2+1$", "$\\frac{1}{2}$"},
		},
		{
			name:     "searchdolls",
			a:        searchdolls.New(),
			messages: []string{"doll Ak 5", "doll damage AR-15", "doll foo", "notadoll"},
		},
		{
			name:     "baseballnews",
			a:        baseballnews.New(),
			messages: []string{"野球", "野球速報", "野球 阪神", "野球 ハム"},
		},
		{
			name:     "pigeons",
			a:        pigeons.New(db),
			messages: []string{"鳩"},
		},
	}

	for _, s := range suites {
		fmt.Printf("\n=== %s ===\n", s.name)
		for _, msg := range s.messages {
			resp := s.a.Answer(answerer.MessageData{Message: msg})
			if resp == nil {
				fmt.Printf("  %-20s → nil\n", fmt.Sprintf("%q", msg))
				continue
			}
			preview := resp.Text
			const maxLen = 120
			if len([]rune(preview)) > maxLen {
				preview = string([]rune(preview)[:maxLen]) + "..."
			}
			fmt.Printf("  %-20s → [%s] %s\n", fmt.Sprintf("%q", msg), resp.ReplyType, preview)
		}
	}

	fmt.Println()
}
