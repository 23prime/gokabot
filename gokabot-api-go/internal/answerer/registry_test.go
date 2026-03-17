package answerer

import (
	"strings"
	"testing"
)

type stubAnswerer struct {
	resp *Response
}

func (s *stubAnswerer) Answer(MessageData) *Response {
	return s.resp
}

func TestRegistry_Dispatch_FirstNonNilWins(t *testing.T) {
	first := &stubAnswerer{resp: nil}
	second := &stubAnswerer{resp: &Response{Text: "hello", ReplyType: "text"}}
	third := &stubAnswerer{resp: &Response{Text: "world", ReplyType: "text"}}

	r := NewRegistry(first, second, third)
	got := r.Dispatch(MessageData{Message: "test"})

	if got == nil {
		t.Fatal("Dispatch() got nil, want non-nil")
		return
	}
	if got.Text != "hello" {
		t.Errorf("Text got %q, want %q", got.Text, "hello")
	}
}

func TestRegistry_Dispatch_NilWhenNoMatch(t *testing.T) {
	r := NewRegistry(&stubAnswerer{resp: nil}, &stubAnswerer{resp: nil})
	got := r.Dispatch(MessageData{Message: "test"})
	if got != nil {
		t.Errorf("Dispatch() got %v, want nil", got)
	}
}

func TestRegistry_Dispatch_EmptyRegistry(t *testing.T) {
	r := NewRegistry()
	got := r.Dispatch(MessageData{Message: "test"})
	if got != nil {
		t.Errorf("Dispatch() got %v, want nil", got)
	}
}

func TestRegistry_Dispatch_TruncatesLongResponse(t *testing.T) {
	long := strings.Repeat("あ", maxResponseRunes+10)
	r := NewRegistry(&stubAnswerer{resp: &Response{Text: long, ReplyType: "text"}})

	got := r.Dispatch(MessageData{Message: "test"})
	if got == nil {
		t.Fatal("Dispatch() got nil, want non-nil")
		return
	}

	runes := []rune(got.Text)
	if len(runes) != maxResponseRunes {
		t.Errorf("len(runes) got %d, want %d", len(runes), maxResponseRunes)
	}
}

func TestRegistry_Dispatch_DoesNotTruncateShortResponse(t *testing.T) {
	text := "short"
	r := NewRegistry(&stubAnswerer{resp: &Response{Text: text, ReplyType: "text"}})

	got := r.Dispatch(MessageData{Message: "test"})
	if got == nil {
		t.Fatal("Dispatch() got nil, want non-nil")
		return
	}
	if got.Text != text {
		t.Errorf("Text got %q, want %q", got.Text, text)
	}
}
