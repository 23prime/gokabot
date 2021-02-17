require 'line/bot'

require_relative 'reply'

module Line
  module Callback
    class ReplyToMedia < Reply
      def reply(event)
        case event.type
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          user_id = get_user_id(event)
          user_name = get_user_name(user_id)

          monitor(
            user_id: user_id,
            user_name: user_name,
            group: get_group(event)
          )
        end
      end
    end
  end
end
