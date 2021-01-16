require 'line/bot'

require_relative 'reply'

module Line
  module Callback
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
  end
end
