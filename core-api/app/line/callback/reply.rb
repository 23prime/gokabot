require 'faraday'

require_relative '../../log_config'

module Line
  module Callback
    class Reply
      include LogConfig

      def initialize
        @logger = @@logger.clone
        @logger.progname = self.class.to_s
      end

      def get_user_id(event)
        return event['source']['userId']
      end

      def get_user_name(user_id)
        response = Faraday.new.post do |req|
          req.url "https://api.line.me/v2/bot/profile/#{user_id}"
          req.headers = {
            'Content-type' => 'application/json',
            'Authorization' => "Bearer #{ENV['LINE_CHANNEL_TOKEN']}"
          }
        end

        return JSON.parse(response.body)['displayName']
      rescue => e
        return e.message
      end

      def get_group(event)
        return event['source']['groupId']
      end

      def monitor(msg: 'No message', reply_text: '', user_id: '', user_name: '', group: '')
        @logger.info("From:    [#{user_id} (#{user_name})]")
        @logger.info("Group:   [#{group}]")
        @logger.info("Message: [#{msg}]")
        @logger.info("Reply:   [#{reply_text}]")
      end

      def hello
        reply_text = 'こん'
        monitor(reply_text: reply_text)

        return {
          type: 'text',
          text: reply_text
        }
      end
    end
  end
end
