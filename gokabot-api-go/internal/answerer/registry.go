package answerer

import (
	"log/slog"
	"reflect"
)

const (
	maxResponseRunes = 2000
	maxLogRunes      = 100
)

// Registry holds the answerer chain and dispatches messages to them in order.
type Registry struct {
	answerers []Answerer
}

// NewRegistry creates a Registry with the given answerers in priority order.
func NewRegistry(answerers ...Answerer) *Registry {
	return &Registry{answerers: answerers}
}

// Dispatch iterates through the answerer chain and returns the first non-nil
// response, truncated to maxResponseRunes runes. Returns nil if no answerer
// handles the message.
func (r *Registry) Dispatch(data MessageData) *Response {
	for _, a := range r.answerers {
		resp := a.Answer(data)
		if resp == nil {
			continue
		}

		runes := []rune(resp.Text)
		if len(runes) > maxResponseRunes {
			resp.Text = string(runes[:maxResponseRunes])
		}

		name := reflect.TypeOf(a).Elem().Name()
		slog.Info("answerer matched",
			"answerer", name,
			"msg", truncate(data.Message),
			"reply", truncate(resp.Text),
			"replyType", resp.ReplyType,
		)
		return resp
	}

	slog.Info("answerer matched", "answerer", "none", "msg", truncate(data.Message))
	return nil
}

func truncate(s string) string {
	runes := []rune(s)
	if len(runes) > maxLogRunes {
		return string(runes[:maxLogRunes]) + "..."
	}
	return s
}
