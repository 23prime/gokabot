package nyokki

import (
	"regexp"
	"strconv"
	"strings"
	"sync"

	"github.com/23prime/gokabot-api/internal/answerer"
)

var (
	nyokkiRe = regexp.MustCompile(`(ニョッキ|にょっき|ﾆｮｯｷ)`)
	startRe  = regexp.MustCompile(`(1|１)(にょっき|ニョッキ|ﾆｮｯｷ)`)
	nonDigit = regexp.MustCompile(`[^0-9]`)
)

// Answerer implements the Nyokki counting game.
// The game starts when a user sends "1ニョッキ". Players must count up in order;
// sending the wrong number or a non-nyokki message returns "負けｗｗｗ".
type Answerer struct {
	mu   sync.Mutex
	stat int
}

func New() *Answerer {
	return &Answerer{}
}

func (a *Answerer) Answer(data answerer.MessageData) *answerer.Response {
	a.mu.Lock()
	defer a.mu.Unlock()

	if a.stat <= 0 && !startRe.MatchString(data.Message) {
		return nil
	}

	return a.nyokki(data.Message)
}

func (a *Answerer) nyokki(msg string) *answerer.Response {
	a.stat++

	if nyokkiRe.MatchString(msg) {
		digits := nonDigit.ReplaceAllString(toHalfWidth(msg), "")
		n, err := strconv.Atoi(digits)
		if err == nil && n == a.stat {
			return nil // correct count, game continues
		}
	}

	a.stat = 0
	return &answerer.Response{Text: "負けｗｗｗ", ReplyType: "text"}
}

func toHalfWidth(s string) string {
	var b strings.Builder
	for _, r := range s {
		if r >= '０' && r <= '９' {
			b.WriteRune(r - '０' + '0')
		} else {
			b.WriteRune(r)
		}
	}
	return b.String()
}
