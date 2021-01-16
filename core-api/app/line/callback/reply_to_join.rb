require 'line/bot'

require_relative 'reply'

module Line
  module Callback
    class ReplyToJoin < Reply
      def reply(event)
        case event
        when Line::Bot::Event::Join, Line::Bot::Event::MemberJoined
          return hello
        end
      end
    end
  end
end
