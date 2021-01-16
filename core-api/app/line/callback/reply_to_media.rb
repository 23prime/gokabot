require 'line/bot'

require_relative 'reply'

module Line
  module Callback
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
  end
end
