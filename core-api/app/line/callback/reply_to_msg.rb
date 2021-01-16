require 'line/bot'

require_relative 'reply'
require_relative 'reply_to_text'
require_relative 'reply_to_media'

module Line
  module Callback
    class ReplyToMsg < Reply
      @@msg_types = [
        Line::Callback::ReplyToText,
        Line::Callback::ReplyToMedia
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
  end
end
