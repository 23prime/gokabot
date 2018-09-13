# coding: utf-8
require 'sinatra'
require 'line/bot'
require './app/imports.rb'

$gokabou = Gokabou.new()
$anime = Anime.new()
$tenki = Weather.new()
$web_dict = WebDict::Answerer.new()


def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end


# Make reply for each case.
def reply(event)
  msg = event.message['text']
  mk_reply(msg)
end


def mk_reply(msg) 
  rep_text  = ''
  objs = [
    $web_dict,
    $tenki,
    $anime,
    $gokabou
  ]

  if Nyokki.stat > 0 || msg =~ /(1|１)(ニョッキ|にょっき|ﾆｮｯｷ)/
    rep_text = Nyokki.nyokki(msg)
  else
    for obj in objs do
      if ans = obj.answer(msg)
        rep_text = ans
      end
    end

    case msg
    when /^([ぁ-ん]|[ァ-ン])$/
      rep_text = Denippi.monyo_chk(msg)
    when /鳩|ゆかり|はと/
      rep_text = Pigeons.mail
    end
  end

  reply = {
    type: 'text',
    text: rep_text
  }
  return reply
end


# Execute.
post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        client.reply_message(event['replyToken'], reply(event))
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open('content')
        tf.write(response.body)
      end
    end
  }

  'OK'
end