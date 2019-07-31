require 'sinatra'
require 'line/bot'
require 'dotenv/load'
require 'rest-client'
require_relative './src.rb'

module Main
  class Reply
    attr_accessor :body

    def initialize(event)
      @event = event
      @body = mk_reply
    end

    def mk_reply
      $reply_type = 'text'

      msg = @event.message['text']
      user_id = @event['source']['userId']
      name = get_name(user_id)
      reply_text = mk_reply_text(msg, user_id, name)

      monitor(user_id, name, msg, reply_text)
      reply = mk_reply_body(reply_text)

      return reply
    end

    def get_name(user_id)
      token = ENV['LINE_CHANNEL_TOKEN']
      uri = "https://api.line.me/v2/bot/profile/#{user_id}"

      begin
        res = RestClient.get uri, Authorization: "Bearer #{token}"
        name = JSON.parse(res.body)['displayName']
      rescue => exception
        name = exception.message
      end

      return name
    end

    def mk_reply_text(*msg_data)
      reply_text = ''

      $ANS_OBJS.each do |obj|
        ans = obj.answer(*msg_data)

        begin
          unless ans.nil?
            reply_text = ans[0, 2000]
            break
          end
        rescue => exception
          exception.message
          reply_text = "エラーおつｗｗｗｗｗｗ\n\n> #{exception}"
        end
      end

      return reply_text
    end

    def monitor(user_id, name, msg, reply_text)
      puts "From:    #{user_id} (#{name})"
      puts "Message: #{msg}"
      puts "Reply:   #{reply_text}"
    end

    def mk_reply_body(reply_text)
      case $reply_type
      when 'text'
        return {
          type: 'text',
          text: reply_text
        }
      when 'image'
        return {
          type: 'image',
          originalContentUrl: reply_text,
          previewImageUrl: reply_text
        }
      else
        return nil
      end
    end

    def hello
      msg = 'こん'

      return {
        type: 'text',
        text: msg
      }
    end
  end

  class Main
    attr_accessor :client

    def initialize
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV['LINE_CHANNEL_SECRET']
        config.channel_token = ENV['LINE_CHANNEL_TOKEN']
      }
    end

    def respond_to_events(events)
      events.each { |event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            reply = Reply.new(event)
            @client.reply_message(event['replyToken'], reply.body)

          when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
            response = @client.get_message_content(event.message['id'])
            tf = Tempfile.open('content')
            tf.write(response.body)
          end

        when Line::Bot::Event::Follow, Line::Bot::Event::Join, Line::Bot::Event::MemberJoined
          @client.reply_message(event['replyToken'], Reply.hello)
        end
      }
    end
  end
end

post '/callback' do
  main = Main::Main.new
  client = main.client

  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']

  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  main.respond_to_events(events)
  'OK'
end
