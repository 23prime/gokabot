package line

import (
	"context"
	"testing"
)

// mockClient is a test implementation of Client.
type mockClient struct{}

func (m *mockClient) ReplyText(ctx context.Context, replyToken, text string) error {
	_, _, _ = ctx, replyToken, text
	return nil
}

func (m *mockClient) PushText(ctx context.Context, to, text string) error {
	_, _, _ = ctx, to, text
	return nil
}

// TestClientInterface verifies that mockClient satisfies the Client interface at compile time.
func TestClientInterface(t *testing.T) {
	t.Helper()
	var _ Client = &mockClient{}
}

// TestNew_ErrorWhenEmpty verifies that New returns an error when credentials are empty.
func TestNew_ErrorWhenEmpty(t *testing.T) {
	tests := []struct {
		name          string
		channelSecret string
		channelToken  string
	}{
		{"empty secret", "", "token"},
		{"empty token", "secret", ""},
		{"both empty", "", ""},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := New(tt.channelSecret, tt.channelToken)
			if err == nil {
				t.Error("New() error = nil, want error")
			}
		})
	}
}
