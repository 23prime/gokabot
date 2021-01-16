require 'rest-client'

require_relative '../../log_config'

module Line
  module Callback
    class Reply
      include LogConfig

      def initialize(event)
        @logger = @@logger.clone
        @logger.progname = self.class.to_s

        @event = event
        @user_id = @event['source']['userId']
      end

      def get_name
        token = ENV['LINE_CHANNEL_TOKEN']
        uri = "https://api.line.me/v2/bot/profile/#{@user_id}"

        begin
          res = RestClient.get uri, Authorization: "Bearer #{token}"
          name = JSON.parse(res.body)['displayName']
        rescue => e
          name = e.message
        end

        return name
      end

      def monitor(msg, reply_text)
        @logger.info("From:    #{@user_id} (#{get_name})")
        @logger.info("Group:   #{@event['source']['groupId']}")
        @logger.info("Message: #{msg}")
        @logger.info("Reply:   #{reply_text}")
      end

      def hello
        reply_text = 'こん'
        monitor('No message', reply_text)

        return {
          type: 'text',
          text: reply_text
        }
      end
    end
  end
end
