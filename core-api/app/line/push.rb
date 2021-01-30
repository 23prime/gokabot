require 'net/http'
require 'json'
require 'faraday'

require_relative '../log_config'

module Line
  class Push
    include LogConfig

    def initialize
      @logger = @@logger.clone
      @logger.progname = self.class.to_s
    end

    def send_msg(msg, target_id)
      target_id = ENV.fetch(target_id, target_id)
      @logger.info("Send push message: '#{msg}' to '#{target_id}'")

      begin
        response = Faraday.post do |req|
          req.url 'https://api.line.me/v2/bot/message/push'
          req.body = {
            'to' => target_id,
            'messages' => [
              {
                'type' => 'text',
                'text' => msg
              }
            ]
          }.to_json
          req.headers = {
            'Content-type' => 'application/json',
            'Authorization' => "Bearer #{ENV['LINE_CHANNEL_TOKEN']}"
          }
        end

        @logger.info("Push response status: #{response.status}")
        @logger.info("Push response body: #{response.body}")

        return response.status
      rescue => e
        @logger.error(e)
        return 500
      end
    end
  end
end
