require_relative '../../log_config'
require_relative '../config'

module Line
  module Callback
    class Reply
      include LogConfig
      include Line::Config

      def initialize
        @logger = @@logger.clone
        @logger.progname = self.class.to_s
      end

      def get_user_id(event)
        return event['source']['userId']
      end

      def get_user_name(user_id)
        response = @@client.get_profile(user_id)
        body = JSON.parse(response.body)
        @logger.info("Get #{user_id}'s profile: #{body}")
        return body['displayName'] if response.code == '200'

        error_message = body['message']
        return "#{response.code} #{error_message}"
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
