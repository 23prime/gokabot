package searchdolls

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/23prime/gokabot-api/internal/answerer"
)

func msg(s string) answerer.MessageData {
	return answerer.MessageData{Message: s}
}

func TestAnswer_NoTrigger_ReturnsNil(t *testing.T) {
	a := New()
	for _, s := range []string{"doll", "ドール", "AK-47", "doll", " doll Ak 5"} {
		if got := a.Answer(msg(s)); got != nil {
			t.Errorf("input=%q: got %v, want nil", s, got)
		}
	}
}

func TestAnswer_Found_ReturnsImageURL(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		i := r
		_ = i
		w.WriteHeader(http.StatusOK)
	}))
	defer server.Close()

	a := New()
	a.baseURL = server.URL + "/"

	got := a.Answer(msg("doll Ak 5"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
	}
	if got.ReplyType != "image" {
		t.Errorf("ReplyType got %q, want image", got.ReplyType)
	}
	want := server.URL + "/Ak%205/::ref/Ak%205.jpg"
	if got.Text != want {
		t.Errorf("Text got %q, want %q", got.Text, want)
	}
}

func TestAnswer_NotFound_ReturnsErrorText(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		i := r
		_ = i
		w.WriteHeader(http.StatusNotFound)
	}))
	defer server.Close()

	a := New()
	a.baseURL = server.URL + "/"

	got := a.Answer(msg("doll foo"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
	}
	if got.Text != "該当するドールが見つかりません" {
		t.Errorf("Text got %q, want 該当するドールが見つかりません", got.Text)
	}
	if got.ReplyType != "text" {
		t.Errorf("ReplyType got %q, want text", got.ReplyType)
	}
}

func TestAnswer_DamageVariant(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		i := r
		_ = i
		w.WriteHeader(http.StatusOK)
	}))
	defer server.Close()

	a := New()
	a.baseURL = server.URL + "/"

	got := a.Answer(msg("doll damage AR-15"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
	}
	want := server.URL + "/AR-15/::ref/AR-15_damage.jpg"
	if got.Text != want {
		t.Errorf("Text got %q, want %q", got.Text, want)
	}
}

func TestBuildURL(t *testing.T) {
	a := New()
	tests := []struct {
		dollName string
		want     string
	}{
		{"Ak 5", baseURL + "Ak%205/::ref/Ak%205.jpg"},
		{"AR-15", baseURL + "AR-15/::ref/AR-15.jpg"},
		{"damage AR-15", baseURL + "AR-15/::ref/AR-15_damage.jpg"},
		{"damage Ak 5", baseURL + "Ak%205/::ref/Ak%205_damage.jpg"},
	}
	for _, tt := range tests {
		got := a.buildURL(tt.dollName)
		if got != tt.want {
			t.Errorf("buildURL(%q) = %q, want %q", tt.dollName, got, tt.want)
		}
	}
}
