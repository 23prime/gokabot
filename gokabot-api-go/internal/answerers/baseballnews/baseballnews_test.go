package baseballnews

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/23prime/gokabot-api/internal/answerer"
)

func msg(s string) answerer.MessageData {
	return answerer.MessageData{Message: s}
}

const sampleHTML = `<html><body>
<div id="header_score">
<div class="score_wrap">
  <div class="score_box date"><div>2026<br>3/17 Tue.</div></div>
  <div class="score_box">
    <a href="/scores/2026/0317/f-db-01/">
    <div>
      <img src="/img/logo_f_s.gif" alt="北海道日本ハムファイターズ" class="logo_left">
      <img src="/img/logo_db_s.gif" alt="横浜DeNAベイスターズ" class="logo_right">
      <div class="score">-</div>
      <div class="state">（エスコンＦ）<br>18:00</div>
    </div>
    </a>
  </div>
  <div class="score_box">
    <a href="/scores/2026/0317/m-t-01/">
    <div>
      <img src="/img/logo_m_s.gif" alt="千葉ロッテマリーンズ" class="logo_left">
      <img src="/img/logo_t_s.gif" alt="阪神タイガース" class="logo_right">
      <div class="score">3-2</div>
      <div class="state">（ZOZOマリン）<br>試合終了</div>
    </div>
    </a>
  </div>
</div>
</div>
</body></html>`

func mockNPBServer(body string) *httptest.Server {
	return httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = r
		fmt.Fprintln(w, body)
	}))
}

func TestAnswer_NoTrigger_ReturnsNil(t *testing.T) {
	a := New()
	for _, s := range []string{"野球中継", "baseball", "野球場に行きたい", "野球の"} {
		if got := a.Answer(msg(s)); got != nil {
			t.Errorf("input=%q: got %v, want nil", s, got)
		}
	}
}

func TestAnswer_AllGames(t *testing.T) {
	server := mockNPBServer(sampleHTML)
	defer server.Close()

	a := New()
	a.baseURL = server.URL

	got := a.Answer(msg("野球"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if !strings.Contains(got.Text, "北海道日本ハムファイターズ") {
		t.Errorf("Text got %q, want Fighters", got.Text)
	}
	if !strings.Contains(got.Text, "千葉ロッテマリーンズ") {
		t.Errorf("Text got %q, want Marines", got.Text)
	}
}

func TestAnswer_Trigger_Sokuhoh(t *testing.T) {
	server := mockNPBServer(sampleHTML)
	defer server.Close()

	a := New()
	a.baseURL = server.URL

	got := a.Answer(msg("野球速報"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if !strings.Contains(got.Text, "北海道日本ハムファイターズ") {
		t.Errorf("Text got %q, want games", got.Text)
	}
}

func TestAnswer_TeamFilter_Tigers(t *testing.T) {
	server := mockNPBServer(sampleHTML)
	defer server.Close()

	a := New()
	a.baseURL = server.URL

	got := a.Answer(msg("野球 阪神"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if !strings.Contains(got.Text, "阪神タイガース") {
		t.Errorf("Text got %q, want Tigers", got.Text)
	}
	if strings.Contains(got.Text, "北海道日本ハム") {
		t.Errorf("Text got %q, should not contain Fighters", got.Text)
	}
}

func TestAnswer_TeamFilter_NoMatch_ReturnsNoGame(t *testing.T) {
	server := mockNPBServer(sampleHTML)
	defer server.Close()

	a := New()
	a.baseURL = server.URL

	// 広島 is not in sampleHTML
	got := a.Answer(msg("野球 広島"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if got.Text != "試合はありません" {
		t.Errorf("Text got %q, want %q", got.Text, "試合はありません")
	}
}

func TestAnswer_ScoreFormat_Finished(t *testing.T) {
	server := mockNPBServer(sampleHTML)
	defer server.Close()

	a := New()
	a.baseURL = server.URL

	got := a.Answer(msg("野球 ロッテ"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	// Should include score and state
	if !strings.Contains(got.Text, "3-2") {
		t.Errorf("Text got %q, want score 3-2", got.Text)
	}
	if !strings.Contains(got.Text, "試合終了") {
		t.Errorf("Text got %q, want 試合終了", got.Text)
	}
}

func TestAnswer_ScoreFormat_NotStarted(t *testing.T) {
	server := mockNPBServer(sampleHTML)
	defer server.Close()

	a := New()
	a.baseURL = server.URL

	got := a.Answer(msg("野球 ハム"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	// Not started: show time, not score
	if !strings.Contains(got.Text, "18:00") {
		t.Errorf("Text got %q, want 18:00", got.Text)
	}
}

func TestAnswer_ScrapeError_ReturnsNil(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = r
		w.WriteHeader(http.StatusInternalServerError)
	}))
	defer server.Close()

	a := New()
	a.baseURL = server.URL

	if got := a.Answer(msg("野球")); got != nil {
		t.Errorf("got %v, want nil on scrape error", got)
	}
}

func TestParseState(t *testing.T) {
	tests := []struct {
		input string
		want  string
	}{
		{"（ZOZOマリン）試合終了", "試合終了"},
		{"（エスコンＦ）18:00", "18:00"},
		{"（甲子園）3回表", "3回表"},
		{"試合終了", "試合終了"},
	}
	for _, tt := range tests {
		got := parseState(tt.input)
		if got != tt.want {
			t.Errorf("parseState(%q) = %q, want %q", tt.input, got, tt.want)
		}
	}
}

func TestMatchTeam(t *testing.T) {
	tests := []struct {
		input string
		want  string
	}{
		{"阪神", "阪神"},
		{"虎", "阪神"},
		{"T", "阪神"},
		{"ハム", "日本ハム"},
		{"ロッテ", "千葉ロッテ"},
		{"広島", "広島"},
		{"不明チーム", ""},
	}
	for _, tt := range tests {
		got := matchTeam(tt.input)
		if got != tt.want {
			t.Errorf("matchTeam(%q) = %q, want %q", tt.input, got, tt.want)
		}
	}
}
