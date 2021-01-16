require 'line/bot'

require_relative 'reply'

module Line
  module Callback
    class ReplyToText < Reply
      def initialize(event)
        super(event)
      end

      def reply
        case @event.type
        when Line::Bot::Event::MessageType::Text
          $reply_type = 'text'
          msg = @event.message['text']
          reply_text = mk_reply_text(msg, @user_id, get_name)
          monitor(msg, reply_text)
          reply = mk_reply_body(reply_text)
        end

        return reply
      end

      def mk_reply_text(*msg_data)
        reply_text = ''

        $ANS_OBJS.each do |obj|
          ans = obj.answer(*msg_data)
          unless ans.nil?
            reply_text = ans[0, 2000]
            break
          end
        rescue => e
          e.message
          reply_text = "エラーおつｗｗｗｗｗｗ\n\n> #{e}"
          @logger.error(e.backtrace)
          break
        end

        return reply_text
      end

      def mk_reply_body(reply_text)
        case $reply_type
        when 'text'
          return {
            type: 'text',
            text: reply_text
          }
        when 'image'
          return {
            type: 'image',
            originalContentUrl: reply_text,
            previewImageUrl: reply_text
          }
        else
          return nil
        end
      end
    end
  end
end
