package baseballnews

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"regexp"
	"strings"
	"time"

	"github.com/23prime/gokabot-api/internal/answerer"
	"github.com/PuerkitoBio/goquery"
)

const baseURL = "https://npb.jp"

var triggerRe = regexp.MustCompile(`^野球(速報)?(\s+(\S+))?$`)

// venueRe strips the venue in （）from state text like "（ZOZOマリン）3回表".
var venueRe = regexp.MustCompile(`^（[^）]+）(.*)$`)

type teamPattern struct {
	re   *regexp.Regexp
	name string
}

var teamPatterns = []teamPattern{
	{regexp.MustCompile(`^(巨|ジャイアンツ|読売|G|Ｇ|兎)`), "読売"},
	{regexp.MustCompile(`^(東京ヤクルト|ヤ|スワローズ|S|Ｓ|燕)`), "東京ヤクルト"},
	{regexp.MustCompile(`^(横浜|DeNA|Ｄ|DB|ベイスターズ|星)`), "横浜DeNA"},
	{regexp.MustCompile(`^(中|ドラゴンズ|D|竜)`), "中日"},
	{regexp.MustCompile(`^(タイガース|虎|神|T|阪|Ｔ)`), "阪神"},
	{regexp.MustCompile(`^(広|東洋|カープ|C|鯉)`), "広島"},
	{regexp.MustCompile(`^(埼玉|西武|ライオンズ|L|猫)`), "埼玉西武"},
	{regexp.MustCompile(`^(日|ハム|ファイターズ|F|公)`), "日本ハム"},
	{regexp.MustCompile(`^(千葉|ロッテ|マリーンズ|M|鴎)`), "千葉ロッテ"},
	{regexp.MustCompile(`^(オリックス|オ|バファローズ|B|檻)`), "オリックス"},
	{regexp.MustCompile(`^(ソ|ホークス|H|福岡|SB|鷹)`), "ソフトバンク"},
	{regexp.MustCompile(`^(楽|東北|E|イーグルス|鷲)`), "楽天"},
}

type game struct {
	homeTeam string
	awayTeam string
	score    string
	state    string
}

// Answerer scrapes today's NPB game results from npb.jp.
type Answerer struct {
	client  *http.Client
	baseURL string
}

func New() *Answerer {
	return &Answerer{
		client:  &http.Client{Timeout: 5 * time.Second},
		baseURL: baseURL,
	}
}

func (a *Answerer) Answer(data answerer.MessageData) *answerer.Response {
	m := triggerRe.FindStringSubmatch(data.Message)
	if m == nil {
		return nil
	}
	teamKeyword := strings.TrimSpace(m[3])

	year := time.Now().Year()
	url := fmt.Sprintf("%s/games/%d/", a.baseURL, year)

	games, err := a.scrapeGames(context.Background(), url)
	if err != nil {
		slog.Warn("baseballnews: scrape failed", "error", err)
		return nil
	}

	if teamKeyword != "" {
		if teamName := matchTeam(teamKeyword); teamName != "" {
			games = filterByTeam(games, teamName)
		}
	}

	if len(games) == 0 {
		return &answerer.Response{Text: "試合はありません", ReplyType: "text"}
	}

	return &answerer.Response{Text: formatGames(games), ReplyType: "text"}
}

func (a *Answerer) scrapeGames(ctx context.Context, url string) ([]game, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil) //nolint:gosec
	if err != nil {
		return nil, err
	}
	req.Header.Set("User-Agent", "Mozilla/5.0 (compatible; gokabot)")

	resp, err := a.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close() //nolint:errcheck

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("npb.jp returned status %d", resp.StatusCode)
	}

	doc, err := goquery.NewDocumentFromReader(resp.Body)
	if err != nil {
		return nil, err
	}

	return parseGames(doc), nil
}

func parseGames(doc *goquery.Document) []game {
	var games []game
	doc.Find("#header_score .score_box").Each(func(i int, s *goquery.Selection) {
		_ = i
		// Skip the date box (has class "date")
		if s.HasClass("date") {
			return
		}
		homeTeam := s.Find("img.logo_left").AttrOr("alt", "")
		awayTeam := s.Find("img.logo_right").AttrOr("alt", "")
		score := strings.TrimSpace(s.Find("div.score").Text())
		state := parseState(strings.TrimSpace(s.Find("div.state").Text()))
		if homeTeam != "" && awayTeam != "" {
			games = append(games, game{homeTeam: homeTeam, awayTeam: awayTeam, score: score, state: state})
		}
	})
	return games
}

// parseState strips the venue in （） from state text and returns only the status/time.
func parseState(raw string) string {
	if m := venueRe.FindStringSubmatch(raw); m != nil {
		return strings.TrimSpace(m[1])
	}
	return raw
}

func matchTeam(keyword string) string {
	for _, tp := range teamPatterns {
		if tp.re.MatchString(keyword) {
			return tp.name
		}
	}
	return ""
}

func filterByTeam(games []game, teamName string) []game {
	var result []game
	for _, g := range games {
		if strings.Contains(g.homeTeam, teamName) || strings.Contains(g.awayTeam, teamName) {
			result = append(result, g)
		}
	}
	return result
}

func formatGames(games []game) string {
	var sb strings.Builder
	for i, g := range games {
		if i > 0 {
			sb.WriteString("\n\n")
		}
		fmt.Fprintf(&sb, "%s - %s", g.homeTeam, g.awayTeam)
		if g.score != "-" && g.score != "" {
			fmt.Fprintf(&sb, "\n%s\n%s", g.score, g.state)
		} else {
			fmt.Fprintf(&sb, "\n%s", g.state)
		}
	}
	return sb.String()
}
