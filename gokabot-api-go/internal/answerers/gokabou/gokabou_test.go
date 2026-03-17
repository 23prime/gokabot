package gokabou

import (
	"slices"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"

	"github.com/23prime/gokabot-api/internal/answerer"
)

func msg(s string) answerer.MessageData {
	return answerer.MessageData{Message: s}
}

// newTestAnswerer returns an Answerer backed by sqlmock.
// The mock expects a SELECT for rebuildDict (returns empty) and no further
// calls unless the test sets them up.
func newTestAnswerer(t *testing.T) (*Answerer, sqlmock.Sqlmock) {
	t.Helper()
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New: %v", err)
	}
	t.Cleanup(func() { db.Close() })

	// rebuildDict called from New()
	mock.ExpectQuery(`SELECT sentence FROM gokabot\.gokabous`).
		WillReturnRows(sqlmock.NewRows([]string{"sentence"}))

	a := New(db)
	a.gokabouUID = "" // disable dict updates by default
	return a, mock
}

// ---- Fixed-response tests ----

func TestAnswer_Kon(t *testing.T) {
	a, _ := newTestAnswerer(t)
	for _, s := range []string{"こん", "こんです", "こんｗ", "こんw"} {
		got := a.Answer(msg(s))
		if got == nil || got.Text != "こん" {
			t.Errorf("input=%q: got %v, want こん", s, got)
		}
	}
}

func TestAnswer_Nurupo(t *testing.T) {
	a, _ := newTestAnswerer(t)
	got := a.Answer(msg("ぬるぽ"))
	if got == nil || got.Text != "ｶﾞｯ" {
		t.Errorf("got %v, want ｶﾞｯ", got)
	}
}

func TestAnswer_Death(t *testing.T) {
	a, _ := newTestAnswerer(t)
	got := a.Answer(msg("死ね"))
	if got == nil {
		t.Fatal("got nil, want dead response")
	}
	if !slices.Contains(deads, got.Text) {
		t.Errorf("got %q, want one of deads", got.Text)
	}
}

func TestAnswer_Iku(t *testing.T) {
	a, _ := newTestAnswerer(t)
	got := a.Answer(msg("行くよ"))
	if got == nil || got.Text != "俺もイク！ｗ" {
		t.Errorf("got %v, want 俺もイク！ｗ", got)
	}
}

func TestAnswer_Version(t *testing.T) {
	a, _ := newTestAnswerer(t)
	got := a.Answer(msg("gokabot -v"))
	if got == nil || got.Text != version {
		t.Errorf("got %v, want %q", got, version)
	}
}

func TestAnswer_Help(t *testing.T) {
	a, _ := newTestAnswerer(t)
	got := a.Answer(msg("gokabot -h"))
	if got == nil || got.Text != help {
		t.Errorf("got %v, want help text", got)
	}
}

func TestAnswer_Omikuji(t *testing.T) {
	a, _ := newTestAnswerer(t)
	got := a.Answer(msg("おみくじ"))
	if got == nil {
		t.Fatal("got nil, want omikuji response")
	}
	if !slices.Contains(omikuji, got.Text) {
		t.Errorf("got %q, want one of omikuji", got.Text)
	}
}

func TestAnswer_Takenoko(t *testing.T) {
	a, _ := newTestAnswerer(t)
	got := a.Answer(msg("たけのこ君"))
	if got == nil || got.Text != "たけのこ君ｐｒｐｒ" {
		t.Errorf("got %v, want たけのこ君ｐｒｐｒ", got)
	}
}

func TestAnswer_NoTrigger_ReturnsNil(t *testing.T) {
	a, _ := newTestAnswerer(t)
	for _, s := range []string{"天気", "アニメ", "hello", "野球"} {
		if got := a.Answer(msg(s)); got != nil {
			t.Errorf("input=%q: got %v, want nil", s, got)
		}
	}
}

// ---- Markov trigger ----

func TestAnswer_MarkovTrigger_ReturnsText(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New: %v", err)
	}
	defer db.Close()

	// rebuildDict from New(): return two sentences
	rows := sqlmock.NewRows([]string{"sentence"}).
		AddRow("ヒゲが好きです").
		AddRow("ヒゲが濃い")
	mock.ExpectQuery(`SELECT sentence FROM gokabot\.gokabous`).WillReturnRows(rows)

	a := New(db)
	a.gokabouUID = "" // no updates

	got := a.Answer(msg("ごかぼう"))
	if got == nil {
		t.Fatal("got nil, want markov text")
	}
	if got.ReplyType != "text" {
		t.Errorf("ReplyType got %q, want text", got.ReplyType)
	}
}

// ---- buildBlocks ----

func TestBuildBlocks_ThreeWords(t *testing.T) {
	words := []string{"A", "B", "C"}
	got := buildBlocks(words)
	want := []markovBlock{
		{sentinel, "A", "B"},
		{"A", "B", "C"},
		{"B", "C", sentinel},
	}
	if len(got) != len(want) {
		t.Fatalf("len got %d, want %d", len(got), len(want))
	}
	for i, b := range got {
		if b != want[i] {
			t.Errorf("block[%d] got %v, want %v", i, b, want[i])
		}
	}
}

func TestBuildBlocks_OneWord(t *testing.T) {
	got := buildBlocks([]string{"A"})
	want := []markovBlock{{sentinel, "A", sentinel}}
	if len(got) != 1 || got[0] != want[0] {
		t.Errorf("got %v, want %v", got, want)
	}
}

func TestBuildBlocks_Empty(t *testing.T) {
	if got := buildBlocks(nil); got != nil {
		t.Errorf("got %v, want nil", got)
	}
}

// ---- genMarkovText ----

func TestGenMarkovText_SingleSentence(t *testing.T) {
	dict := buildBlocks([]string{"猫", "は", "可愛い"})
	got := genMarkovText(dict)
	if got != "猫は可愛い" {
		t.Errorf("got %q, want %q", got, "猫は可愛い")
	}
}

func TestGenMarkovText_EmptyDict(t *testing.T) {
	got := genMarkovText(nil)
	if got != "…" {
		t.Errorf("got %q, want %q", got, "…")
	}
}
