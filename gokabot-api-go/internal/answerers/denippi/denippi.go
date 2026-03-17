package denippi

import (
	"math/rand/v2"
	"regexp"
	"sync"

	"github.com/23prime/gokabot-api/internal/answerer"
)

var triggerRe = regexp.MustCompile(`^([ぁ-ん]|[ァ-ン]|寝)$|^うん$`)

// Answerer responds to single kana characters with a random kana of the same
// script on every 2nd message, and replies "そ" to "ね" or "寝".
type Answerer struct {
	mu    sync.Mutex
	count int
}

func New() *Answerer {
	return &Answerer{}
}

func (a *Answerer) Answer(data answerer.MessageData) *answerer.Response {
	if !triggerRe.MatchString(data.Message) {
		return nil
	}

	a.mu.Lock()
	defer a.mu.Unlock()

	if a.count >= 2 {
		a.count = 0
	}

	return a.monyoChk(data.Message)
}

func (a *Answerer) monyoChk(msg string) *answerer.Response {
	if msg == "ね" || msg == "寝" {
		return &answerer.Response{Text: "そ", ReplyType: "text"}
	}

	a.count++

	if a.count == 2 {
		runes := []rune(msg)
		r := runes[0]
		switch {
		case r >= 'ぁ' && r <= 'ん':
			return &answerer.Response{Text: string(randomHiragana()), ReplyType: "text"}
		case r >= 'ァ' && r <= 'ン':
			return &answerer.Response{Text: string(randomKatakana()), ReplyType: "text"}
		}
	}

	return nil
}

func randomHiragana() rune {
	return rune('ぁ') + rune(rand.IntN(int('ん'-'ぁ'+1))) //nolint:gosec
}

func randomKatakana() rune {
	return rune('ァ') + rune(rand.IntN(int('ン'-'ァ'+1))) //nolint:gosec
}
