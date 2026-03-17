package webdict

import (
	"context"
	"log/slog"
	"math/rand/v2"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"time"

	"github.com/23prime/gokabot-api/internal/answerer"
	"github.com/PuerkitoBio/goquery"
)

const minAbstractLen = 50

var notFoundMessages = []string{
	"知りませ〜んｗｗｗｗｗ",
	"そんなことも知らねえのかテメェは",
}

// queryRe extracts the keyword from interrogative messages like "Xって？", "Xとは".
// Matches the Ruby NORMAL_QUESTION_REG pattern.
var queryRe = regexp.MustCompile(
	`(?P<query>[^\n\r\f.,．。，、]+[.,．。，、]*)` +
		`(?:って[?？]` +
		`|とは[.?．。？]?$` +
		`|(?:とは|って)(?:なに|何|誰|だれ|どこ|(?:なん|何|誰|だれ|どこ)(?:なの|だよ|だょ|ですか|のこ))[.?．。？]?$)`,
)

type source struct {
	baseURL    string
	selector   string
	singleElem bool
	cleanup    func(*goquery.Document)
}

var defaultSources = []source{
	{
		baseURL:  "http://dic.nicovideo.jp/a/",
		selector: "div#article > p",
		cleanup:  func(doc *goquery.Document) { doc.Find("sup > a.dic").Remove() },
	},
	{
		baseURL:    "https://dic.pixiv.net/a/",
		selector:   "div.summary",
		singleElem: true,
	},
	{
		baseURL:  "https://ja.wikipedia.org/wiki/",
		selector: "div.mw-parser-output > p, div.mw-parser-output > ul",
		cleanup:  func(doc *goquery.Document) { doc.Find("sup.reference").Remove() },
	},
	{
		baseURL:  "https://en.wikipedia.org/wiki/",
		selector: "div.mw-parser-output > p, div.mw-parser-output > ul",
		cleanup:  func(doc *goquery.Document) { doc.Find("sup.reference").Remove() },
	},
}

// Answerer searches multiple web dictionaries in parallel and returns the
// first non-empty result in priority order: Niconico → Pixiv → Wikipedia (ja) → Wikipedia (en).
type Answerer struct {
	client  *http.Client
	sources []source
}

func New() *Answerer {
	return &Answerer{
		client:  &http.Client{Timeout: 5 * time.Second},
		sources: defaultSources,
	}
}

func (a *Answerer) Answer(data answerer.MessageData) *answerer.Response {
	keyword := extractKeyword(data.Message)
	if keyword == "" {
		return nil
	}

	result := a.search(keyword)
	if result == "" {
		result = notFoundMessages[rand.IntN(len(notFoundMessages))] //nolint:gosec
	}
	return &answerer.Response{Text: result, ReplyType: "text"}
}

func extractKeyword(msg string) string {
	m := queryRe.FindStringSubmatch(msg)
	if m == nil {
		return ""
	}
	idx := queryRe.SubexpIndex("query")
	return strings.TrimSpace(m[idx])
}

func (a *Answerer) search(keyword string) string {
	type result struct {
		text string
		idx  int
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	ch := make(chan result, len(a.sources))

	for i, src := range a.sources {
		go func() {
			text, err := a.scrape(ctx, src, keyword)
			if err != nil {
				slog.Warn("webdict: scrape failed", "source", src.baseURL, "error", err)
			}
			ch <- result{text, i}
		}()
	}

	texts := make([]string, len(a.sources))
	for range a.sources {
		r := <-ch
		texts[r.idx] = r.text
	}

	for _, text := range texts {
		if text != "" {
			return text
		}
	}
	return ""
}

func (a *Answerer) scrape(ctx context.Context, src source, keyword string) (string, error) {
	u := src.baseURL + url.QueryEscape(keyword)
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil) //nolint:gosec
	if err != nil {
		return "", err
	}
	req.Header.Set("User-Agent", "Mozilla/5.0 (compatible; gokabot)")

	resp, err := a.client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close() //nolint:errcheck

	if resp.StatusCode >= 400 {
		return "", nil
	}

	doc, err := goquery.NewDocumentFromReader(resp.Body)
	if err != nil {
		return "", err
	}

	if src.cleanup != nil {
		src.cleanup(doc)
	}

	return extractText(doc, src.selector, src.singleElem), nil
}

func extractText(doc *goquery.Document, selector string, singleElem bool) string {
	var sb strings.Builder
	doc.Find(selector).EachWithBreak(func(i int, s *goquery.Selection) bool {
		if singleElem && i > 0 {
			return false
		}
		text := strings.TrimSpace(s.Text())
		text = strings.Join(strings.Fields(text), " ")
		if text == "" {
			return true
		}
		if sb.Len() > 0 {
			sb.WriteByte('\n')
		}
		sb.WriteString(text)
		return sb.Len() < minAbstractLen
	})
	return sb.String()
}
