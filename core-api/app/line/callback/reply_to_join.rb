require 'line/bot'

require_relative 'reply'

module Line
  module Callback
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
  end
end
