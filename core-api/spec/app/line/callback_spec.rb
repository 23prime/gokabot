describe 'LINE Callback test' do
  let!(:client) {
    Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  }

  let(:body_message) {
    {
      'destination' => 'xxxxxxxxxx',
      'events' => [
        {
          'replyToken' => '0f3779fba3b349968c5d07db31eab56f',
          'type' => 'message',
          'timestamp' => 1_462_629_479_859,
          'source' => {
            'type' => 'user',
            'userId' => 'Ue0000000000000000000000000000000'
          },
          'message' => {
            'id' => '325708',
            'type' => 'text',
            'text' => 'ぬるぽ'
          }
        }
      ]
    }
  }

  let(:result_message) {
    {
      type: 'text',
      text: 'ｶﾞｯ'
    }
  }

  let(:body_follow) {
    {
      'destination' => 'xxxxxxxxxx',
      'events' => [
        {
          'replyToken' => '8cf9239d56244f4197887e939187e19e',
          'type' => 'follow',
          'timestamp' => 1_462_629_479_859,
          'source' => {
            'type' => 'user',
            'userId' => 'U4af4980629...'
          }
        }
      ]
    }
  }

  let(:result_follow) {
    {
      type: 'text',
      text: 'こん'
    }
  }

  before do
    stub_request(:post, 'https://api.line.me/v2/bot/message/reply').to_return(status: 200)
    stub_request(:get, 'https://api.line.me/v2/bot/profile/Ue0000000000000000000000000000000').to_return(status: 200)
  end

  it 'Callback for Message event' do
    body = JSON.dump(body_message)
    events = client.parse_events_from(body)
    reply = Line::Callback.respond_to_events(events)
    expect(reply).to eq result_message
  end

  it 'Callback for Follow event' do
    body = JSON.dump(body_follow)
    events = client.parse_events_from(body)
    reply = Line::Callback.respond_to_events(events)
    expect(reply).to eq result_follow
  end
end
