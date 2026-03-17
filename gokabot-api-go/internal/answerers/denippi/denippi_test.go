package denippi

import (
	"testing"

	"github.com/23prime/gokabot-api/internal/answerer"
)

func msg(s string) answerer.MessageData {
	return answerer.MessageData{Message: s}
}

func TestAnswer_NonTrigger_ReturnsNil(t *testing.T) {
	a := New()
	for _, s := range []string{"hello", "こんにちは", "ABC", "123"} {
		if got := a.Answer(msg(s)); got != nil {
			t.Errorf("input=%q: got %v, want nil", s, got)
		}
	}
}

func TestAnswer_Ne_ReturnsSo(t *testing.T) {
	a := New()
	for _, s := range []string{"ね", "寝"} {
		got := a.Answer(msg(s))
		if got == nil || got.Text != "そ" {
			t.Errorf("input=%q: got %v, want Text=%q", s, got, "そ")
		}
	}
}

func TestAnswer_SingleHiragana_SecondReturnsHiragana(t *testing.T) {
	a := New()

	// 1st → no response
	if got := a.Answer(msg("あ")); got != nil {
		t.Errorf("1st: got %v, want nil", got)
	}
	// 2nd → random hiragana
	got := a.Answer(msg("い"))
	if got == nil {
		t.Fatal("2nd: got nil, want non-nil")
		return
	}
	r := []rune(got.Text)
	if len(r) != 1 || r[0] < 'ぁ' || r[0] > 'ん' {
		t.Errorf("2nd: got %q, want single hiragana", got.Text)
	}
}

func TestAnswer_SingleKatakana_SecondReturnsKatakana(t *testing.T) {
	a := New()

	if got := a.Answer(msg("ア")); got != nil {
		t.Errorf("1st: got %v, want nil", got)
	}
	got := a.Answer(msg("イ"))
	if got == nil {
		t.Fatal("2nd: got nil, want non-nil")
		return
	}
	r := []rune(got.Text)
	if len(r) != 1 || r[0] < 'ァ' || r[0] > 'ン' {
		t.Errorf("2nd: got %q, want single katakana", got.Text)
	}
}

func TestAnswer_CountResetAfterSecond(t *testing.T) {
	a := New()

	a.Answer(msg("あ")) // count=1
	a.Answer(msg("い")) // count=2, response
	// count resets to 0 on next call

	if got := a.Answer(msg("う")); got != nil {
		t.Errorf("after reset: got %v, want nil", got)
	}
}

func TestAnswer_Un_IncrementsCountSilently(t *testing.T) {
	a := New()

	// "うん" increments count but returns nil
	if got := a.Answer(msg("うん")); got != nil {
		t.Errorf("うん: got %v, want nil", got)
	}
	// next single hiragana should be the 2nd → response
	got := a.Answer(msg("あ"))
	if got == nil {
		t.Error("after うん: got nil, want non-nil")
	}
}
