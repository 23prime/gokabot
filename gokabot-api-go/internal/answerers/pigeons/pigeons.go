package pigeons

import (
	_ "embed"
	"encoding/csv"
	"math/rand/v2"
	"regexp"
	"strings"

	"github.com/23prime/gokabot-api/internal/answerer"
)

//go:embed yukarinmails.csv
var mailsCSV []byte

var triggerRe = regexp.MustCompile(`鳩|ゆかり|はと`)

// Answerer responds to messages containing "鳩", "ゆかり", or "はと" with a
// random mail from yukarinmails.csv (subject + newline + body).
type Answerer struct {
	mails [][3]string // [date, subject, body]
}

func New() *Answerer {
	r := csv.NewReader(strings.NewReader(string(mailsCSV)))
	r.FieldsPerRecord = -1 // allow variable fields
	records, err := r.ReadAll()
	if err != nil {
		panic("pigeons: failed to parse yukarinmails.csv: " + err.Error())
	}

	var mails [][3]string
	for _, rec := range records {
		if len(rec) >= 3 {
			mails = append(mails, [3]string{rec[0], rec[1], rec[2]})
		}
	}

	return &Answerer{mails: mails}
}

func (a *Answerer) Answer(data answerer.MessageData) *answerer.Response {
	if !triggerRe.MatchString(data.Message) {
		return nil
	}

	mail := a.mails[rand.IntN(len(a.mails))] //nolint:gosec
	return &answerer.Response{
		Text:      mail[1] + "\n" + mail[2],
		ReplyType: "text",
	}
}
