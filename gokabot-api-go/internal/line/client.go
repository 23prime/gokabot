package line

import (
	"context"
	"fmt"

	"github.com/line/line-bot-sdk-go/v8/linebot"
)

// Client is the interface for LINE Bot operations.
type Client interface {
	ReplyText(context.Context, string, string) error
	PushText(context.Context, string, string) error
}

type lineClient struct {
	bot *linebot.Client
}

// New creates a new LINE Client. Returns an error if channelSecret or channelToken is empty.
func New(channelSecret, channelToken string) (Client, error) {
	if channelSecret == "" || channelToken == "" {
		return nil, fmt.Errorf("channelSecret and channelToken must not be empty")
	}

	bot, err := linebot.New(channelSecret, channelToken)
	if err != nil {
		return nil, fmt.Errorf("failed to create LINE bot client: %w", err)
	}

	return &lineClient{bot: bot}, nil
}

func (c *lineClient) ReplyText(ctx context.Context, replyToken, text string) error {
	_, err := c.bot.ReplyMessage(replyToken, linebot.NewTextMessage(text)).WithContext(ctx).Do()
	if err != nil {
		return fmt.Errorf("failed to reply message: %w", err)
	}
	return nil
}

func (c *lineClient) PushText(ctx context.Context, to, text string) error {
	_, err := c.bot.PushMessage(to, linebot.NewTextMessage(text)).WithContext(ctx).Do()
	if err != nil {
		return fmt.Errorf("failed to push message: %w", err)
	}
	return nil
}
