package webdict

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"slices"
	"strings"
	"testing"

	"github.com/23prime/gokabot-api/internal/answerer"
)

func msg(s string) answerer.MessageData {
	return answerer.MessageData{Message: s}
}

func TestExtractKeyword(t *testing.T) {
	tests := []struct {
		input string
		want  string
	}{
		{"猫って？", "猫"},
		{"猫って?", "猫"},
		{"猫とは", "猫"},
		{"猫とは？", "猫"},
		{"猫とは。", "猫"},
		{"猫とはなに", "猫"},
		{"猫とはなに？", "猫"},
		{"猫ってなに", "猫"},
		{"猫って何", "猫"},
		{"猫って誰", "猫"},
		{"猫ってなんなの", "猫"},
		{"猫ってなんだよ", "猫"},
		{"ゴジラとはなんですか", "ゴジラ"},
		// Non-trigger
		{"猫が好き", ""},
		{"hello", ""},
		{"天気", ""},
	}
	for _, tt := range tests {
		got := extractKeyword(tt.input)
		if got != tt.want {
			t.Errorf("extractKeyword(%q) = %q, want %q", tt.input, got, tt.want)
		}
	}
}

func TestAnswer_NoTrigger_ReturnsNil(t *testing.T) {
	a := New()
	for _, s := range []string{"hello", "猫が好き", "天気", "とは"} {
		if got := a.Answer(msg(s)); got != nil {
			t.Errorf("input=%q: got %v, want nil", s, got)
		}
	}
}

func TestAnswer_AllSourcesFail_ReturnsNotFound(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = r
		w.WriteHeader(http.StatusNotFound)
	}))
	defer server.Close()

	a := New()
	a.sources = []source{
		{baseURL: server.URL + "/", selector: "p"},
	}

	got := a.Answer(msg("猫とは"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if !slices.Contains(notFoundMessages, got.Text) {
		t.Errorf("Text got %q, want one of notFoundMessages", got.Text)
	}
}

func TestAnswer_FirstSourceReturnsResult(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = r
		fmt.Fprintln(w, `<html><body><p>猫とはネコ科の動物で、人間と長い歴史をともにしてきたペットです。</p></body></html>`)
	}))
	defer server.Close()

	a := New()
	a.sources = []source{
		{baseURL: server.URL + "/", selector: "p"},
	}

	got := a.Answer(msg("猫とは"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if got.ReplyType != "text" {
		t.Errorf("ReplyType got %q, want %q", got.ReplyType, "text")
	}
	if got.Text == "" {
		t.Error("Text got empty, want non-empty")
	}
}

func TestAnswer_PriorityOrder_FirstNonEmpty(t *testing.T) {
	emptyServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = r
		fmt.Fprintln(w, `<html><body></body></html>`)
	}))
	defer emptyServer.Close()

	resultServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = r
		fmt.Fprintln(w, `<html><body><p>second source result: ゴジラとは怪獣映画の主人公であり、日本の特撮文化を代表するキャラクターです。</p></body></html>`)
	}))
	defer resultServer.Close()

	a := New()
	a.sources = []source{
		{baseURL: emptyServer.URL + "/", selector: "p"},
		{baseURL: resultServer.URL + "/", selector: "p"},
	}

	got := a.Answer(msg("ゴジラとは"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if !strings.Contains(got.Text, "second source result") {
		t.Errorf("Text got %q, want result from second source", got.Text)
	}
}

func TestAnswer_SingleElem_OnlyFirstElement(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = r
		fmt.Fprintln(w, `<html><body>
			<div class="summary"><p>first paragraph text about the topic here</p></div>
			<div class="summary"><p>second paragraph should not appear</p></div>
		</body></html>`)
	}))
	defer server.Close()

	a := New()
	a.sources = []source{
		{baseURL: server.URL + "/", selector: "div.summary", singleElem: true},
	}

	got := a.Answer(msg("猫とは"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if strings.Contains(got.Text, "second paragraph") {
		t.Errorf("Text got %q, should not contain second element", got.Text)
	}
}
