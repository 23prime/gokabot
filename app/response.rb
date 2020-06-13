require 'dotenv/load'
require 'line/bot'
require 'rest-client'

require './app/log_config'
require_relative 'src'

module Response
  class Reply
    include LogConfig

    def initialize(event)
      @@logger.progname = self.class.to_s

      @event = event
      @user_id = @event['source']['userId']
    end

    def get_name
      token = ENV['LINE_CHANNEL_TOKEN']
      uri = "https://api.line.me/v2/bot/profile/#{@user_id}"

      begin
        res = RestClient.get uri, Authorization: "Bearer #{token}"
        name = JSON.parse(res.body)['displayName']
      rescue => e
        name = e.message
      end

      return name
    end

    def monitor(msg, reply_text)
      @@logger.info("From:    #{@user_id} (#{get_name})")
      @@logger.info("Group:   #{@event['source']['groupId']}")
      @@logger.info("Message: #{msg}")
      @@logger.info("Reply:   #{reply_text}")
    end

    def hello
      reply_text = 'こん'
      monitor('No message', reply_text)

      return {
        type: 'text',
        text: reply_text
      }
    end
  end

  class ReplyToText < Reply
    def initialize(event)
      super(event)
    end

    def reply
      case @event.type
      when Line::Bot::Event::MessageType::Text
        $reply_type = 'text'
        msg = @event.message['text']
        reply_text = mk_reply_text(msg, @user_id, get_name)
        monitor(msg, reply_text)
        reply = mk_reply_body(reply_text)
      end

      return reply
    end

    def mk_reply_text(*msg_data)
      reply_text = ''

      $ANS_OBJS.each do |obj|
        ans = obj.answer(*msg_data)
        unless ans.nil?
          reply_text = ans[0, 2000]
          break
        end
      rescue => e
        e.message
        reply_text = "エラーおつｗｗｗｗｗｗ\n\n> #{e}"
        @@logger.error(e.backtrace)
        break
      end

      return reply_text
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
  end

  class ReplyToMedia < Reply
    def initialize(event)
      super(event)
    end

    def reply
      case @event.type
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        monitor('Media', 'No reply')
      end
    end
  end

  class ReplyToFollow < Reply
    def initialize(event)
      super(event)
    end

    def reply
      case @event
      when Line::Bot::Event::Follow
        return hello
      end
    end
  end

  class ReplyToMsg < Reply
    @@msg_types = [
      ReplyToText,
      ReplyToMedia
    ]

    def initialize(event)
      super(event)
    end

    def reply
      case @event
      when Line::Bot::Event::Message
        @@msg_types.each do |mt|
          reply = mt.new(@event).reply
          return reply unless reply.nil?
        end
      end
    end
  end

  class ReplyToJoin < Reply
    def initialize(event)
      super(event)
    end

    def reply
      case @event
      when Line::Bot::Event::Join, Line::Bot::Event::MemberJoined
        return hello
      end
    end
  end

  class Response
    @@event_classes = [
      ReplyToMsg,
      ReplyToFollow,
      ReplyToJoin
    ]

    def self.client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV['LINE_CHANNEL_SECRET']
        config.channel_token = ENV['LINE_CHANNEL_TOKEN']
      }
    end

    def self.response(body, signature)
      unless client.validate_signature(body, signature)
        error 400 do 'Bad Request' end
      end

      events = client.parse_events_from(body)
      respond_to_events(events)
    end

    def self.respond_to_events(events)
      events.each do |event|
        @@event_classes.each do |ec|
          reply = ec.new(event).reply

          unless reply.nil?
            client.reply_message(event['replyToken'], reply)
            return reply
          end
        end
      end
    end
  end
end
