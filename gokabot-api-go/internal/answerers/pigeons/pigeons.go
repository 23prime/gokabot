package pigeons

import (
	"context"
	"database/sql"
	"fmt"
	"log/slog"
	"regexp"

	"github.com/23prime/gokabot-api/internal/answerer"
)

var triggerRe = regexp.MustCompile(`鳩|ゆかり|はと`)

const query = `
SELECT subject, body
FROM gokabot.yukarin_mails
OFFSET FLOOR(RANDOM() * (SELECT COUNT(*) FROM gokabot.yukarin_mails))
LIMIT 1`

// Answerer responds to messages containing "鳩", "ゆかり", or "はと" with a
// random mail from the yukarin_mails table (subject + newline + body).
type Answerer struct {
	db *sql.DB
}

func New(db *sql.DB) *Answerer {
	return &Answerer{db: db}
}

func (a *Answerer) Answer(data answerer.MessageData) *answerer.Response {
	if !triggerRe.MatchString(data.Message) {
		return nil
	}

	subject, body, err := a.pickMail(context.Background())
	if err != nil {
		slog.Warn("pigeons: failed to pick mail", "error", err)
		return nil
	}

	return &answerer.Response{
		Text:      fmt.Sprintf("%s\n%s", subject, body),
		ReplyType: "text",
	}
}

func (a *Answerer) pickMail(ctx context.Context) (subject, body string, err error) {
	row := a.db.QueryRowContext(ctx, query)
	err = row.Scan(&subject, &body)
	return
}
