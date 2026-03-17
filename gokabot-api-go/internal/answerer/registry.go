package answerer

const maxResponseRunes = 2000

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

		return resp
	}

	return nil
}
