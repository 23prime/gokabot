package pigeons

import (
	"strings"
	"testing"

	"github.com/23prime/gokabot-api/internal/answerer"
)

func msg(s string) answerer.MessageData {
	return answerer.MessageData{Message: s}
}

func TestNew_LoadsMailsFromCSV(t *testing.T) {
	a := New()
	if len(a.mails) == 0 {
		t.Error("mails is empty, want non-empty")
	}
}

func TestAnswer_NoMatch_ReturnsNil(t *testing.T) {
	a := New()
	for _, s := range []string{"hello", "猫", "pigeon"} {
		if got := a.Answer(msg(s)); got != nil {
			t.Errorf("input=%q: got %v, want nil", s, got)
		}
	}
}

func TestAnswer_Trigger_ReturnsMailText(t *testing.T) {
	a := New()
	for _, s := range []string{"鳩", "ゆかり", "はと", "鳩が来た"} {
		got := a.Answer(msg(s))
		if got == nil {
			t.Errorf("input=%q: got nil, want non-nil", s)
			continue
		}
		if !strings.Contains(got.Text, "\n") {
			t.Errorf("input=%q: Text %q missing newline between subject and body", s, got.Text)
		}
	}
}
