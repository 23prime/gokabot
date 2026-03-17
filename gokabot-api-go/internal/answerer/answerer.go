package answerer

// MessageData holds the data extracted from an incoming LINE message event.
type MessageData struct {
	Message  string
	UserID   string
	UserName string
}

// Response is the reply to be sent back to the user.
type Response struct {
	Text      string
	ReplyType string // "text" or "image"
}

// Answerer is implemented by each answerer in the chain.
// Answer returns a non-nil Response if the answerer handles the message,
// or nil to pass to the next answerer.
type Answerer interface {
	Answer(MessageData) *Response
}
