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

    def send_msg(msg, target)
      @logger.info("Send push message: '#{msg}' to '#{target}'")

      target_id = ENV[target]

      if target_id.nil?
        @logger.error('Push target is nil.')
        return 401
      end

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
