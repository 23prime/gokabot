require 'line/bot'

require_relative 'reply'

module Line
  module Callback
    class ReplyToFollow < Reply
      def reply(event)
        case event
        when Line::Bot::Event::Follow
          return hello
        end
      end
    end
  end
end
