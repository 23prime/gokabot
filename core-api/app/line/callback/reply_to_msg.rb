require 'line/bot'

require_relative 'reply'
require_relative 'reply_to_text'
require_relative 'reply_to_media'

module Line
  module Callback
    class ReplyToMsg < Reply
      @@msg_types = [
        Line::Callback::ReplyToText.new,
        Line::Callback::ReplyToMedia.new
      ]

      def reply(event)
        case event
        when Line::Bot::Event::Message
          @@msg_types.each do |mt|
            reply = mt.reply(event)
            return reply unless reply.nil?
          end
        end
      end
    end
  end
end
