package weather

import (
	"database/sql"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	sqlmock "github.com/DATA-DOG/go-sqlmock"

	"github.com/23prime/gokabot-api/internal/answerer"
)

func msg(s string) answerer.MessageData {
	return answerer.MessageData{Message: s}
}

func cityRows(id int) *sqlmock.Rows {
	return sqlmock.NewRows([]string{"id"}).AddRow(id)
}

func mockWeatherServer(body string) *httptest.Server {
	return httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = r
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintln(w, body)
	}))
}

func TestAnswer_NoTrigger_ReturnsNil(t *testing.T) {
	db, _, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	a := New(db, "key")
	for _, s := range []string{"hello", "天", "今日の天気予報", "weather", "大阪の天気"} {
		if got := a.Answer(msg(s)); got != nil {
			t.Errorf("input=%q: got %v, want nil", s, got)
		}
	}
}

func TestAnswer_CityNotFound_ReturnsError(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	mock.ExpectQuery(`SELECT id FROM gokabot.cities`).WillReturnError(sql.ErrNoRows)

	a := New(db, "key")
	got := a.Answer(msg("天気"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if got.Text != "分かりませ〜んｗ" {
		t.Errorf("Text got %q, want %q", got.Text, "分かりませ〜んｗ")
	}
}

func TestAnswer_APIError_ReturnsError(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	mock.ExpectQuery(`SELECT id FROM gokabot.cities`).WillReturnRows(cityRows(1850147))

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = r
		w.WriteHeader(http.StatusInternalServerError)
	}))
	defer server.Close()

	a := New(db, "key")
	a.apiBase = server.URL

	got := a.Answer(msg("天気"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if got.Text != "天気を取得できませんでした〜ｗ" {
		t.Errorf("Text got %q, want %q", got.Text, "天気を取得できませんでした〜ｗ")
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_Success_DefaultCity(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	mock.ExpectQuery(`SELECT id FROM gokabot.cities`).WillReturnRows(cityRows(1850147))

	server := mockWeatherServer(`{"weather":[{"main":"Clear"}],"main":{"temp":22.5,"temp_min":18,"temp_max":25}}`)
	defer server.Close()

	a := New(db, "testkey")
	a.apiBase = server.URL

	got := a.Answer(msg("天気"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if got.ReplyType != "text" {
		t.Errorf("ReplyType got %q, want %q", got.ReplyType, "text")
	}
	want := "> 東京の現在の天気 <\nClear\n現在の気温：22.5℃\n最高気温：25℃\n最低気温：18℃"
	if got.Text != want {
		t.Errorf("Text got %q, want %q", got.Text, want)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_Success_TodayNotenki(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	mock.ExpectQuery(`SELECT id FROM gokabot.cities`).WillReturnRows(cityRows(1850147))

	server := mockWeatherServer(`{"weather":[{"main":"Clouds"}],"main":{"temp":20,"temp_min":15,"temp_max":22}}`)
	defer server.Close()

	a := New(db, "testkey")
	a.apiBase = server.URL

	got := a.Answer(msg("今日の天気"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_WithCity_Osaka(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	mock.ExpectQuery(`SELECT id FROM gokabot.cities`).WillReturnRows(cityRows(1853909))

	server := mockWeatherServer(`{"weather":[{"main":"Rain"}],"main":{"temp":18,"temp_min":15,"temp_max":20}}`)
	defer server.Close()

	a := New(db, "testkey")
	a.apiBase = server.URL

	got := a.Answer(msg("天気 大阪"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if !strings.Contains(got.Text, "大阪") {
		t.Errorf("Text got %q, want to contain city name", got.Text)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_WithCity_EnglishCapitalized(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	mock.ExpectQuery(`SELECT id FROM gokabot.cities`).WillReturnRows(cityRows(1850147))

	server := mockWeatherServer(`{"weather":[{"main":"Clear"}],"main":{"temp":22,"temp_min":18,"temp_max":25}}`)
	defer server.Close()

	a := New(db, "testkey")
	a.apiBase = server.URL

	// "Tokyo" lowercased → "tokyo" → display as "Tokyo"
	got := a.Answer(msg("天気 Tokyo"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if !strings.Contains(got.Text, "Tokyo") {
		t.Errorf("Text got %q, want to contain 'Tokyo'", got.Text)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}
