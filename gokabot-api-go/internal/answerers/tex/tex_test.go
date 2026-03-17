package tex

import (
	"strings"
	"testing"

	"github.com/23prime/gokabot-api/internal/answerer"
)

func msg(s string) answerer.MessageData {
	return answerer.MessageData{Message: s}
}

func TestAnswer_NoMatch_ReturnsNil(t *testing.T) {
	a := New()
	for _, s := range []string{"hello", "formula", "$", "$$", "$x"} {
		if got := a.Answer(msg(s)); got != nil {
			t.Errorf("input=%q: got %v, want nil", s, got)
		}
	}
}

func TestAnswer_Japanese_ReturnsError(t *testing.T) {
	a := New()
	got := a.Answer(msg("$日本語$"))
	if got == nil || got.Text != "日本語禁止" {
		t.Errorf("got %v, want Text=%q", got, "日本語禁止")
	}
}

func TestAnswer_TooLong_ReturnsError(t *testing.T) {
	a := New()
	long := "$" + strings.Repeat("x", maxTeXLen) + "$"
	got := a.Answer(msg(long))
	if got == nil || got.Text != "長すぎだよ" {
		t.Errorf("got %v, want Text=%q", got, "長すぎだよ")
	}
}

func TestAnswer_ValidFormula_ReturnsImageURL(t *testing.T) {
	a := New()
	got := a.Answer(msg("$E=mc^2$"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if got.ReplyType != "image" {
		t.Errorf("ReplyType got %q, want %q", got.ReplyType, "image")
	}
	if !strings.HasPrefix(got.Text, baseURL) {
		t.Errorf("Text got %q, want prefix %q", got.Text, baseURL)
	}
	if !strings.Contains(got.Text, "E%3Dmc%5E2") {
		t.Errorf("Text got %q, want encoded formula", got.Text)
	}
}

func TestAnswer_MultilineFormula(t *testing.T) {
	a := New()
	got := a.Answer(msg("$a=1\nb=2$"))
	if got == nil || got.ReplyType != "image" {
		t.Errorf("got %v, want image response", got)
	}
}

func TestAnswer_LiteralNewlineStripped(t *testing.T) {
	a := New()
	got := a.Answer(msg(`$a\nb$`))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if strings.Contains(got.Text, `\n`) {
		t.Errorf("Text still contains literal \\n: %q", got.Text)
	}
}
