package searchdolls

import (
	"context"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/23prime/gokabot-api/internal/answerer"
)

const baseURL = "https://cdn.wikiwiki.jp/to/w/dolls-fl/"

// Answerer looks up Girls' Frontline doll images on cdn.wikiwiki.jp.
// Trigger: "doll <name>" or "doll damage <name>"
type Answerer struct {
	client  *http.Client
	baseURL string
}

func New() *Answerer {
	return &Answerer{
		client:  &http.Client{Timeout: 5 * time.Second},
		baseURL: baseURL,
	}
}

func (a *Answerer) Answer(data answerer.MessageData) *answerer.Response {
	msg := data.Message
	if !strings.HasPrefix(msg, "doll ") {
		return nil
	}

	dollName := strings.TrimPrefix(msg, "doll ")
	imageURL := a.buildURL(dollName)

	if !a.fetchable(imageURL) {
		return &answerer.Response{Text: "該当するドールが見つかりません", ReplyType: "text"}
	}
	return &answerer.Response{Text: imageURL, ReplyType: "image"}
}

// buildURL constructs the wikiwiki image URL for the given doll name.
// "damage <name>" appends "_damage" to the filename.
func (a *Answerer) buildURL(dollName string) string {
	isDamage := strings.HasPrefix(dollName, "damage ")
	if isDamage {
		dollName = strings.TrimPrefix(dollName, "damage ")
	}

	encoded := url.PathEscape(dollName)
	fileName := encoded
	if isDamage {
		fileName += "_damage"
	}

	return fmt.Sprintf("%s%s/::ref/%s.jpg", a.baseURL, encoded, fileName)
}

func (a *Answerer) fetchable(imageURL string) bool {
	req, err := http.NewRequestWithContext(context.Background(), http.MethodGet, imageURL, nil) //nolint:gosec
	if err != nil {
		return false
	}

	resp, err := a.client.Do(req)
	if err != nil {
		return false
	}
	defer resp.Body.Close() //nolint:errcheck

	return resp.StatusCode < 400
}
