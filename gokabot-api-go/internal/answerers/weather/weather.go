package weather

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"strings"
	"unicode"

	"github.com/23prime/gokabot-api/internal/answerer"
)

const (
	defaultCity    = "東京"
	openWeatherURL = "https://api.openweathermap.org/data/2.5/weather"
)

type weatherResp struct {
	Weather []struct {
		Main string `json:"main"`
	} `json:"weather"`
	Main struct {
		Temp    float64 `json:"temp"`
		TempMin float64 `json:"temp_min"`
		TempMax float64 `json:"temp_max"`
	} `json:"main"`
}

// Answerer responds to weather queries by looking up cities in the DB and
// fetching current conditions from the OpenWeatherMap API.
type Answerer struct {
	db      *sql.DB
	apiKey  string
	client  *http.Client
	apiBase string
}

func New(db *sql.DB, apiKey string) *Answerer {
	return &Answerer{
		db:      db,
		apiKey:  apiKey,
		client:  http.DefaultClient,
		apiBase: openWeatherURL,
	}
}

func (a *Answerer) Answer(data answerer.MessageData) *answerer.Response {
	parts := strings.Fields(data.Message)
	if len(parts) == 0 {
		return nil
	}

	msg0 := parts[0]
	if msg0 != "天気" && msg0 != "今日の天気" && msg0 != "明日の天気" {
		return nil
	}

	cityName := defaultCity
	if len(parts) > 1 {
		cityName = strings.ToLower(parts[1])
	}

	cityID, err := a.lookupCity(context.Background(), cityName)
	if err != nil {
		slog.Warn("weather: city not found", "city", cityName)
		return &answerer.Response{Text: "分かりませ〜んｗ", ReplyType: "text"}
	}

	info, err := a.fetchWeather(cityID)
	if err != nil {
		slog.Warn("weather: fetch failed", "error", err)
		return &answerer.Response{Text: "天気を取得できませんでした〜ｗ", ReplyType: "text"}
	}

	displayCity := capitalize(cityName)
	text := fmt.Sprintf(
		"> %sの現在の天気 <\n%s\n現在の気温：%g℃\n最高気温：%g℃\n最低気温：%g℃",
		displayCity,
		info.Weather[0].Main,
		info.Main.Temp,
		info.Main.TempMax,
		info.Main.TempMin,
	)
	return &answerer.Response{Text: text, ReplyType: "text"}
}

func (a *Answerer) lookupCity(ctx context.Context, name string) (int, error) {
	var id int
	err := a.db.QueryRowContext(ctx,
		`SELECT id FROM gokabot.cities WHERE LOWER(name) = LOWER($1) OR jp_name = $1 LIMIT 1`,
		name,
	).Scan(&id)
	if errors.Is(err, sql.ErrNoRows) {
		return 0, fmt.Errorf("city not found: %s", name)
	}
	return id, err
}

func (a *Answerer) fetchWeather(cityID int) (*weatherResp, error) {
	url := fmt.Sprintf("%s?appid=%s&id=%d&units=metric", a.apiBase, a.apiKey, cityID)
	resp, err := a.client.Get(url) //nolint:gosec
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close() //nolint:errcheck

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("weather API returned status %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var data weatherResp
	if err := json.Unmarshal(body, &data); err != nil {
		return nil, err
	}

	if len(data.Weather) == 0 {
		return nil, fmt.Errorf("empty weather array in response")
	}

	return &data, nil
}

// capitalize uppercases the first rune ("osaka" → "Osaka", "東京" → "東京").
func capitalize(s string) string {
	runes := []rune(s)
	if len(runes) == 0 {
		return s
	}
	return string(unicode.ToUpper(runes[0])) + string(runes[1:])
}
