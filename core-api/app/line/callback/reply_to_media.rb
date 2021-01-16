require 'line/bot'

require_relative 'reply'

module Line
  module Callback
    class ReplyToMedia < Reply
      def reply(event)
        case event.type
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          monitor('Media', 'No reply')
        end
      end
    end
  end
end
