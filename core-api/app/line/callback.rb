require_relative '../log_config'
require_relative 'config'

require_relative 'callback/reply_to_msg'
require_relative 'callback/reply_to_follow'
require_relative 'callback/reply_to_join'

module Line
  module Callback
    include Line::Config

    @@event_types = [
      Line::Callback::ReplyToMsg.new,
      Line::Callback::ReplyToFollow.new,
      Line::Callback::ReplyToJoin.new
    ]

    def self.response(body, signature)
      unless @@client.validate_signature(body, signature)
        error 400 do 'Bad Request' end
      end

      events = @@client.parse_events_from(body)
      respond_to_events(events)
    end

    def self.respond_to_events(events)
      events.each do |event|
        @@event_types.each do |ec|
          reply = ec.reply(event)

          unless reply.nil?
            @@client.reply_message(event['replyToken'], reply)
            return reply
          end
        end
      end
    end
  end
end
