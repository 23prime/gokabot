package tex

import (
	"net/url"
	"regexp"
	"strings"

	"github.com/23prime/gokabot-api/internal/answerer"
)

const (
	baseURL   = "https://chart.googleapis.com/chart?cht=tx&chs=200&chl="
	maxTeXLen = 200
)

var (
	// (?s) makes . match newlines, allowing multi-line formulas
	texRe   = regexp.MustCompile(`(?s)^\$.+\$$`)
	nonASCI = regexp.MustCompile(`[^\x01-\x7E]`)
)

type Answerer struct{}

func New() *Answerer { return &Answerer{} }

func (a *Answerer) Answer(data answerer.MessageData) *answerer.Response {
	msg := data.Message

	if !texRe.MatchString(msg) {
		return nil
	}

	if nonASCI.MatchString(msg) {
		return &answerer.Response{Text: "日本語禁止", ReplyType: "text"}
	}

	// Strip surrounding $
	msg = msg[1 : len(msg)-1]

	if len(msg) >= maxTeXLen {
		return &answerer.Response{Text: "長すぎだよ", ReplyType: "text"}
	}

	// Remove literal \n sequences (LaTeX line break notation)
	msg = strings.ReplaceAll(msg, `\n`, "")

	return &answerer.Response{
		Text:      baseURL + url.QueryEscape(msg),
		ReplyType: "image",
	}
}
