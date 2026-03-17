package nyokki

import (
	"testing"

	"github.com/23prime/gokabot-api/internal/answerer"
)

func msg(s string) answerer.MessageData {
	return answerer.MessageData{Message: s}
}

func TestAnswer_NotInGame_ReturnsNil(t *testing.T) {
	a := New()
	if got := a.Answer(msg("hello")); got != nil {
		t.Errorf("got %v, want nil", got)
	}
}

func TestAnswer_GameSequence(t *testing.T) {
	a := New()

	steps := []struct {
		input string
		want  string // empty = want nil
	}{
		{"1ニョッキ", ""},      // start, correct
		{"2ニョッキ", ""},      // correct
		{"3ニョッキ", ""},      // correct
		{"5ニョッキ", "負けｗｗｗ"}, // wrong (expected 4)
		{"1ニョッキ", ""},      // game restarted, correct
	}

	for _, s := range steps {
		got := a.Answer(msg(s.input))
		if s.want == "" {
			if got != nil {
				t.Errorf("input=%q: got %v, want nil", s.input, got)
			}
		} else {
			if got == nil || got.Text != s.want {
				t.Errorf("input=%q: got %v, want Text=%q", s.input, got, s.want)
			}
		}
	}
}

func TestAnswer_NonNyokkiDuringGame(t *testing.T) {
	a := New()

	a.Answer(msg("1ニョッキ")) // start game

	got := a.Answer(msg("hello"))
	if got == nil || got.Text != "負けｗｗｗ" {
		t.Errorf("got %v, want Text=%q", got, "負けｗｗｗ")
	}
}

func TestAnswer_FullWidthNumber(t *testing.T) {
	a := New()

	if got := a.Answer(msg("１ニョッキ")); got != nil {
		t.Errorf("got %v, want nil", got)
	}
	if got := a.Answer(msg("２ニョッキ")); got != nil {
		t.Errorf("got %v, want nil", got)
	}
}

func TestAnswer_HiraganaVariant(t *testing.T) {
	a := New()

	if got := a.Answer(msg("1にょっき")); got != nil {
		t.Errorf("got %v, want nil", got)
	}
}
