package anime

import (
	"cmp"
	"context"
	"database/sql"
	"fmt"
	"log/slog"
	"regexp"
	"slices"
	"strings"
	"time"

	"github.com/23prime/gokabot-api/internal/answerer"
	"github.com/23prime/gokabot-api/internal/database/models"
)

var jst = time.FixedZone("JST", 9*60*60)

var wdays = [7]string{"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}

var seasons = [4]string{"winter", "spring", "summer", "fall"}

var wdayOrder = map[string]int{
	"Sun": 0, "Mon": 1, "Tue": 2, "Wed": 3, "Thu": 4, "Fri": 5, "Sat": 6,
}

type converterEntry struct {
	re  *regexp.Regexp
	day func(int) string
}

// converters maps message patterns to a canonical form used in answerWith.
// Uppercase weekday = all animes; lowercase = recommended only.
var converters = []converterEntry{
	// Weekday name patterns
	{regexp.MustCompile(`(?i)^sun(day)?$|^日曜(日)?(のアニメ)?$`), func(int) string { return "Sun" }},
	{regexp.MustCompile(`(?i)^mon(day)?$|^月曜(日)?(のアニメ)?$`), func(int) string { return "Mon" }},
	{regexp.MustCompile(`(?i)^tue(sday)?$|^火曜(日)?(のアニメ)?$`), func(int) string { return "Tue" }},
	{regexp.MustCompile(`(?i)^wed(nesday)?$|^水曜(日)?(のアニメ)?$`), func(int) string { return "Wed" }},
	{regexp.MustCompile(`(?i)^thu(rsday)?$|^木曜(日)?(のアニメ)?$`), func(int) string { return "Thu" }},
	{regexp.MustCompile(`(?i)^fri(day)?$|^金曜(日)?(のアニメ)?$`), func(int) string { return "Fri" }},
	{regexp.MustCompile(`(?i)^sat(urday)?$|^土曜(日)?(のアニメ)?$`), func(int) string { return "Sat" }},
	// Relative day → uppercase weekday (all animes)
	{regexp.MustCompile(`(?i)^(一昨日(のアニメ)?|day before yesterday)$`), func(today int) string { return wdays[(today-2+7)%7] }},
	{regexp.MustCompile(`(?i)^(昨日(のアニメ)?|yesterday)$`), func(today int) string { return wdays[(today-1+7)%7] }},
	{regexp.MustCompile(`(?i)^(今日(のアニメ)?|today)$`), func(today int) string { return wdays[today] }},
	{regexp.MustCompile(`(?i)^(明日(のアニメ)?|tomorrow)$`), func(today int) string { return wdays[(today+1)%7] }},
	{regexp.MustCompile(`(?i)^(明後日(のアニメ)?|day after tomorrow)$`), func(today int) string { return wdays[(today+2)%7] }},
	// Relative day + recommend → lowercase weekday (recommended only)
	{regexp.MustCompile(`^一昨日の(おすすめ|オススメ)$`), func(today int) string { return strings.ToLower(wdays[(today-2+7)%7]) }},
	{regexp.MustCompile(`^昨日の(おすすめ|オススメ)$`), func(today int) string { return strings.ToLower(wdays[(today-1+7)%7]) }},
	{regexp.MustCompile(`^(今日の)?(おすすめ|オススメ)$`), func(today int) string { return strings.ToLower(wdays[today]) }},
	{regexp.MustCompile(`^明日の(おすすめ|オススメ)$`), func(today int) string { return strings.ToLower(wdays[(today+1)%7]) }},
	{regexp.MustCompile(`^明後日の(おすすめ|オススメ)$`), func(today int) string { return strings.ToLower(wdays[(today+2)%7]) }},
}

var (
	allCurrentRe = regexp.MustCompile(`(?i)^all$|^今期(のアニメ)?$`)
	rcmCurrentRe = regexp.MustCompile(`^今期の(おすすめ|オススメ)$`)
	allNextRe    = regexp.MustCompile(`(?i)^next$|^来期(のアニメ)?$`)
	rcmNextRe    = regexp.MustCompile(`^来期の(おすすめ|オススメ)$`)
	weekdayRe    = regexp.MustCompile(`^(Sun|Mon|Tue|Wed|Thu|Fri|Sat)$`)
	weekRcmRe    = regexp.MustCompile(`^(sun|mon|tue|wed|thu|fri|sat)$`)
)

// Answerer responds to anime schedule queries.
type Answerer struct {
	db *sql.DB
}

func New(db *sql.DB) *Answerer {
	return &Answerer{db: db}
}

func (a *Answerer) Answer(data answerer.MessageData) *answerer.Response {
	now := time.Now().In(jst)
	year, season, today := nowParts(now)
	return a.answerWith(data, year, season, today)
}

func (a *Answerer) answerWith(data answerer.MessageData, year int, season string, today int) *answerer.Response {
	msg := convertMsg(data.Message, today)

	var (
		text string
		err  error
	)

	switch {
	case allCurrentRe.MatchString(msg):
		text, err = a.formatAnimes(context.Background(), year, season, "", false)
	case rcmCurrentRe.MatchString(msg):
		text, err = a.formatAnimes(context.Background(), year, season, "", true)
	case allNextRe.MatchString(msg):
		ny, ns := nextSeason(year, season)
		text, err = a.formatAnimes(context.Background(), ny, ns, "", false)
	case rcmNextRe.MatchString(msg):
		ny, ns := nextSeason(year, season)
		text, err = a.formatAnimes(context.Background(), ny, ns, "", true)
	case weekdayRe.MatchString(msg):
		text, err = a.formatAnimes(context.Background(), year, season, msg, false)
	case weekRcmRe.MatchString(msg):
		text, err = a.formatAnimes(context.Background(), year, season, capitalize(msg), true)
	default:
		return nil
	}

	if err != nil {
		slog.Warn("anime: query failed", "error", err)
		return nil
	}

	return &answerer.Response{Text: text, ReplyType: "text"}
}

func nowParts(t time.Time) (int, string, int) {
	return t.Year(), seasons[(t.Month()-1)/3], int(t.Weekday())
}

func nextSeason(year int, season string) (int, string) {
	for i, s := range seasons {
		if s == season {
			next := (i + 1) % 4
			if next == 0 {
				year++
			}
			return year, seasons[next]
		}
	}
	return year, season
}

func convertMsg(msg string, today int) string {
	for _, c := range converters {
		if c.re.MatchString(msg) {
			return c.day(today)
		}
	}
	return msg
}

// capitalize uppercases the first rune (ASCII weekday abbreviations like "mon" → "Mon").
func capitalize(s string) string {
	if s == "" {
		return s
	}
	return strings.ToUpper(s[:1]) + s[1:]
}

func (a *Answerer) formatAnimes(ctx context.Context, year int, season, day string, rcm bool) (string, error) {
	animes, err := a.queryAnimes(ctx, year, season, day, rcm)
	if err != nil {
		return "", err
	}

	if len(animes) == 0 {
		if rcm {
			return "ありませ〜んｗｗｗｗ", nil
		}
		return "早漏かよｗ", nil
	}

	includeDay := day == ""
	sortAnimes(animes, includeDay)

	var sb strings.Builder
	for i, anime := range animes {
		if i > 0 {
			sb.WriteByte('\n')
		}
		if includeDay {
			fmt.Fprintf(&sb, "%s, %s, %s, %s", anime.Day, anime.Time, anime.Station, anime.Title)
		} else {
			fmt.Fprintf(&sb, "%s, %s, %s", anime.Time, anime.Station, anime.Title)
		}
	}
	return sb.String(), nil
}

func sortAnimes(animes []models.Anime, byDay bool) {
	slices.SortStableFunc(animes, func(a, b models.Anime) int {
		if byDay {
			if d := cmp.Compare(wdayOrder[a.Day], wdayOrder[b.Day]); d != 0 {
				return d
			}
		}
		return cmp.Compare(a.Time, b.Time)
	})
}

func (a *Answerer) queryAnimes(ctx context.Context, year int, season, day string, rcm bool) ([]models.Anime, error) {
	q := `SELECT year, season, day, time, station, title, recommend
FROM gokabot.animes
WHERE year = $1 AND season = $2`
	args := []any{year, season}
	n := 3

	if day != "" {
		q += fmt.Sprintf(` AND day = $%d`, n)
		args = append(args, day)
		n++
	}
	if rcm {
		q += ` AND recommend = true`
	}
	_ = n

	rows, err := a.db.QueryContext(ctx, q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close() //nolint:errcheck

	var result []models.Anime
	for rows.Next() {
		var anime models.Anime
		if err := rows.Scan(&anime.Year, &anime.Season, &anime.Day, &anime.Time, &anime.Station, &anime.Title, &anime.Recommend); err != nil {
			return nil, err
		}
		result = append(result, anime)
	}
	return result, rows.Err()
}
