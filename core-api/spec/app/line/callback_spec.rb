describe 'LINE Callback test' do
  let(:body_message) {
    '{
        "destination": "xxxxxxxxxx",
        "events": [
          {
          "replyToken": "0f3779fba3b349968c5d07db31eab56f",
            "type": "message",
            "timestamp": 1462629479859,
            "source": {
              "type": "user",
              "userId": "U0123456789abcdefghijklmnopqrstuv"
            },
            "message": {
              "id": "325708",
              "type": "text",
              "text": "ぬるぽ"
            }
          }
        ]
      }'
  }

  let(:result_message) {
    {
      type: 'text',
      text: 'ｶﾞｯ'
    }
  }

  let(:body_follow) {
    '{
        "destination": "xxxxxxxxxx",
        "events": [
          {
            "replyToken": "8cf9239d56244f4197887e939187e19e",
            "type": "follow",
            "timestamp": 1462629479859,
            "source": {
              "type": "user",
              "userId": "U4af4980629..."
            }
          }
        ]
      }'
  }

  let(:result_follow) {
    {
      type: 'text',
      text: 'こん'
    }
  }

  it 'Callback for Message event' do
    events = Line::Callback.client.parse_events_from(body_message)
    reply = Line::Callback.respond_to_events(events)
    expect(reply).to eq result_message
  end

  it 'Callback for Follow event' do
    events = Line::Callback.client.parse_events_from(body_follow)
    reply = Line::Callback.respond_to_events(events)
    expect(reply).to eq result_follow
  end
end
