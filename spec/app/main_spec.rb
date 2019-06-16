describe 'Reply test' do
  let(:request_body) {
    '{
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
    }'
  }

  let(:json) { JSON.parse(request_body) }
  let(:event) { Line::Bot::Event::Message.new(json) }

  let(:true_reply) {
    {
      type: 'text',
      text: 'ｶﾞｯ'
    }
  }

  it 'NullPointer' do
    # reply_text = mk_reply_text(msg, user_id, name)
    # expect(reply_text).to eq 'ｶﾞｯ'

    reply = reply(event)
    expect(reply).to eq true_reply
  end
end
