package pigeons

import (
	"fmt"
	"testing"

	sqlmock "github.com/DATA-DOG/go-sqlmock"

	"github.com/23prime/gokabot-api/internal/answerer"
)

func msg(s string) answerer.MessageData {
	return answerer.MessageData{Message: s}
}

func TestAnswer_NoMatch_ReturnsNil(t *testing.T) {
	db, _, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	a := New(db)
	for _, s := range []string{"hello", "猫", "pigeon"} {
		if got := a.Answer(msg(s)); got != nil {
			t.Errorf("input=%q: got %v, want nil", s, got)
		}
	}
}

func TestAnswer_Trigger_ReturnsMailText(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	rows := sqlmock.NewRows([]string{"subject", "body"}).
		AddRow("9/10", "とんこつラーメン食べたい\n田村ゆかり")
	mock.ExpectQuery(`SELECT subject, body`).WillReturnRows(rows)

	a := New(db)
	got := a.Answer(msg("ゆかり"))
	if got == nil {
		t.Fatal("got nil, want non-nil")
		return
	}
	if got.Text != "9/10\nとんこつラーメン食べたい\n田村ゆかり" {
		t.Errorf("Text got %q", got.Text)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unfulfilled mock expectations: %v", err)
	}
}

func TestAnswer_DBError_ReturnsNil(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close() //nolint:errcheck

	mock.ExpectQuery(`SELECT subject, body`).WillReturnError(fmt.Errorf("db error")) //nolint:err113

	a := New(db)
	if got := a.Answer(msg("鳩")); got != nil {
		t.Errorf("got %v, want nil on DB error", got)
	}
}
