describe 'Reply test' do
  let(:bodies) {
    [
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
      }',
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
    ]
  }

  let(:true_replys) {
    [
      {
        type: 'text',
        text: 'ｶﾞｯ'
      },
      {
        type: 'text',
        text: 'こん'
      }
    ]
  }

  it 'Reply to Text' do
    events = Response::Response.client.parse_events_from(bodies[0])
    reply = Response::Response.respond_to_events(events)
    expect(reply).to eq true_replys[0]
  end

  it 'Reply to Follow' do
    events = Response::Response.client.parse_events_from(bodies[1])
    reply = Response::Response.respond_to_events(events)
    expect(reply).to eq true_replys[1]
  end
end
