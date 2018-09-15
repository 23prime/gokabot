# coding: utf-8
require 'sinatra'
require 'line/bot'
require './app/imports.rb'

$OBJS = [
  Nyokki.new(),
  Gokabou.new(),
  Anime.new(),
  Weather.new(),
  WebDict::Answerer.new(),
  Denippi.new(),
  Tex.new(),
  Pigeons.new()
]

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end


# Make reply for each case.
def reply(event)
  msg = event.message['text']
  return mk_reply(msg)
end


def mk_reply(msg) 
  reply_text  = ''
  $reply_type = 'text'

  $OBJS.each do |obj|
    begin
      if ans = obj.answer(msg)
        reply_text = ans
        break
      end
    rescue => exception
      exception.message
      reply_text = "エラーおつｗｗｗｗｗｗ\n\n> #{exception}"
    end
  end

  case $reply_type
  when 'text'
    reply = {
      type: 'text',
      text: reply_text
    }
  when 'image'
    reply = {
      type: 'image',
      originalContentUrl: reply_text,
      previewImageUrl: reply_text
    }
  end

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
