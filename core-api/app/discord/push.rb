require 'dotenv/load'

require_relative '../log_config'

module Discord
  class Push
    include Discord::Config
    include LogConfig

    @@default_target_id = ENV['DISCORD_TARGET_CHANNEL_ID']

    def initialize
      @logger = @@logger.clone
      @logger.progname = self.class.to_s
    end

    def send_message(msg, target_id)
      target_id ||= @@default_target_id
      @logger.info("Send push message: '#{msg}' to '#{target_id}'")

      @@bot.send_message(target_id.to_i, msg, false, nil)
      return 200
    rescue RestClient::BadRequest, RestClient::Forbidden, RestClient::NotFound => e
      @logger.error("Failed to request to Discord: #{e}")
      return e.http_code
    rescue => e
      @logger.error("Failed to request to Discord: #{e}")
      return 500
    end
  end
end
