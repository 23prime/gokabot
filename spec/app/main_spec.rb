describe 'Reply test' do
  let(:body) { '
    {
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
        },
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

  let(:true_reply) {
    {
      type: 'text',
      text: 'ｶﾞｯ'
    }
  }

  it 'NullPointer' do
    body0 = Sinatra::Request.request.body.read
    main = Main::Main.new
    events = main.client.parse_events_from(body)
    event = events[0]
    reply = Main::Reply.new(event)
    expect(reply.body).to eq true_reply
  end
end
