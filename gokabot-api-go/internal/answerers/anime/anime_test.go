package anime

import (
	"fmt"
	"testing"

	"github.com/23prime/gokabot-api/internal/answerer"
	sqlmock "github.com/DATA-DOG/go-sqlmock"
)

func msg(s string) answerer.MessageData {
	return answerer.MessageData{Message: s}
}

func animeRows() *sqlmock.Rows {
	return sqlmock.NewRows([]string{"year", "season", "day", "time", "station", "title", "recommend"})
}

// winter 2026, today=1 (Monday) used as a fixed reference point in tests.
const (
	testYear   = 2026
	testSeason = "winter"
	testToday  = 1 // Monday
)

func TestAnswer_NoMatch_ReturnsNil(t *testing.T) {
	db, _, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	a := New(db)
	for _, s := range []string{"hello", "アニメ", "今期", "来期"} {
		if got := a.answerWith(msg(s), testYear, testSeason, testToday); got != nil {
			t.Errorf("input=%q: got %v, want nil", s, got)
		}
	}
}

func TestAnswer_AllCurrent_ReturnsAllSorted(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	rows := animeRows().
		AddRow(2026, "winter", "Tue", "22:00", "BS11", "Anime B", false).
		AddRow(2026, "winter", "Mon", "23:00", "TOKYO MX", "Anime A", true)
	mock.ExpectQuery(`SELECT year, season, day, time, station, title, recommend`).WillReturnRows(rows)

	a := New(db)
	got := a.answerWith(msg("今期のアニメ"), testYear, testSeason, testToday)
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	// Sorted by day (Mon=1, Tue=2), then time
	want := "Mon, 23:00, TOKYO MX, Anime A\nTue, 22:00, BS11, Anime B"
	if got.Text != want {
		t.Errorf("Text got %q, want %q", got.Text, want)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_AllCurrent_AllKeyword(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	rows := animeRows().AddRow(2026, "winter", "Mon", "23:00", "TOKYO MX", "Anime A", true)
	mock.ExpectQuery(`SELECT year, season, day, time, station, title, recommend`).WillReturnRows(rows)

	a := New(db)
	got := a.answerWith(msg("all"), testYear, testSeason, testToday)
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_RecommendCurrent(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	rows := animeRows().AddRow(2026, "winter", "Mon", "23:00", "TOKYO MX", "Anime A", true)
	mock.ExpectQuery(`SELECT year, season, day, time, station, title, recommend`).WillReturnRows(rows)

	a := New(db)
	got := a.answerWith(msg("今期のおすすめ"), testYear, testSeason, testToday)
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	// Season-wide queries include the day in output (all: true in Ruby equivalent)
	if got.Text != "Mon, 23:00, TOKYO MX, Anime A" {
		t.Errorf("Text got %q", got.Text)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_AllNext_Spring(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	rows := animeRows().AddRow(2026, "spring", "Wed", "24:00", "BS11", "Spring Anime", false)
	mock.ExpectQuery(`SELECT year, season, day, time, station, title, recommend`).WillReturnRows(rows)

	a := New(db)
	got := a.answerWith(msg("来期のアニメ"), testYear, testSeason, testToday)
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	want := "Wed, 24:00, BS11, Spring Anime"
	if got.Text != want {
		t.Errorf("Text got %q, want %q", got.Text, want)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_NextKeyword(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	rows := animeRows().AddRow(2026, "spring", "Mon", "23:00", "TOKYO MX", "Spring Anime A", true)
	mock.ExpectQuery(`SELECT year, season, day, time, station, title, recommend`).WillReturnRows(rows)

	a := New(db)
	got := a.answerWith(msg("next"), testYear, testSeason, testToday)
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_Weekday_Mon(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	// Return in reverse time order to verify sorting
	rows := animeRows().
		AddRow(2026, "winter", "Mon", "24:00", "BS11", "Anime B", false).
		AddRow(2026, "winter", "Mon", "23:00", "TOKYO MX", "Anime A", true)
	mock.ExpectQuery(`SELECT year, season, day, time, station, title, recommend`).WillReturnRows(rows)

	a := New(db)
	got := a.answerWith(msg("Mon"), testYear, testSeason, testToday)
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	// Day-specific: no day prefix, sorted by time
	want := "23:00, TOKYO MX, Anime A\n24:00, BS11, Anime B"
	if got.Text != want {
		t.Errorf("Text got %q, want %q", got.Text, want)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_JapaneseWeekday(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	rows := animeRows().AddRow(2026, "winter", "Mon", "23:00", "TOKYO MX", "Anime A", true)
	mock.ExpectQuery(`SELECT year, season, day, time, station, title, recommend`).WillReturnRows(rows)

	a := New(db)
	got := a.answerWith(msg("月曜日のアニメ"), testYear, testSeason, testToday)
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_TodayAnime(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	rows := animeRows().AddRow(2026, "winter", "Mon", "23:00", "TOKYO MX", "Anime A", true)
	mock.ExpectQuery(`SELECT year, season, day, time, station, title, recommend`).WillReturnRows(rows)

	a := New(db)
	// today=1 (Monday), so "今日のアニメ" → Mon
	got := a.answerWith(msg("今日のアニメ"), testYear, testSeason, testToday)
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_WeekdayRecommend(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	rows := animeRows().AddRow(2026, "winter", "Mon", "23:00", "TOKYO MX", "Anime A", true)
	mock.ExpectQuery(`SELECT year, season, day, time, station, title, recommend`).WillReturnRows(rows)

	a := New(db)
	// English lowercase weekday triggers day-specific recommend (Ruby WEEK_RCM pattern)
	got := a.answerWith(msg("mon"), testYear, testSeason, testToday)
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_TodayRecommend(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	rows := animeRows().AddRow(2026, "winter", "Mon", "23:00", "TOKYO MX", "Anime A", true)
	mock.ExpectQuery(`SELECT year, season, day, time, station, title, recommend`).WillReturnRows(rows)

	a := New(db)
	// today=1 (Monday), so "おすすめ" → mon → Mon recommend
	got := a.answerWith(msg("おすすめ"), testYear, testSeason, testToday)
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_EmptyResult_AllQuery(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	mock.ExpectQuery(`SELECT year, season, day, time, station, title, recommend`).WillReturnRows(animeRows())

	a := New(db)
	got := a.answerWith(msg("今期のアニメ"), testYear, testSeason, testToday)
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if got.Text != "早漏かよｗ" {
		t.Errorf("Text got %q, want %q", got.Text, "早漏かよｗ")
	}
}

func TestAnswer_EmptyResult_RecommendQuery(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	mock.ExpectQuery(`SELECT year, season, day, time, station, title, recommend`).WillReturnRows(animeRows())

	a := New(db)
	got := a.answerWith(msg("今期のおすすめ"), testYear, testSeason, testToday)
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if got.Text != "ありませ〜んｗｗｗｗ" {
		t.Errorf("Text got %q, want %q", got.Text, "ありませ〜んｗｗｗｗ")
	}
}

func TestAnswer_DBError_ReturnsNil(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	mock.ExpectQuery(`SELECT year, season, day, time, station, title, recommend`).
		WillReturnError(fmt.Errorf("db error")) //nolint:err113

	a := New(db)
	if got := a.answerWith(msg("今期のアニメ"), testYear, testSeason, testToday); got != nil {
		t.Errorf("got %v, want nil on DB error", got)
	}
}

func TestNextSeason(t *testing.T) {
	tests := []struct {
		year   int
		season string
		wantY  int
		wantS  string
	}{
		{2026, "winter", 2026, "spring"},
		{2026, "spring", 2026, "summer"},
		{2026, "summer", 2026, "fall"},
		{2026, "fall", 2027, "winter"},
	}
	for _, tt := range tests {
		y, s := nextSeason(tt.year, tt.season)
		if y != tt.wantY || s != tt.wantS {
			t.Errorf("nextSeason(%d, %q) = (%d, %q), want (%d, %q)", tt.year, tt.season, y, s, tt.wantY, tt.wantS)
		}
	}
}
