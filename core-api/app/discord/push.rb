require 'dotenv/load'

require_relative '../log_config'

module Discord
  class Push
    include Discord::Config
    include LogConfig

    LOGGER = LogConfig.get_logger(name)

    @@default_target_id = ENV['DISCORD_TARGET_CHANNEL_ID']

    def send_message(msg, target_id)
      target_id ||= @@default_target_id
      LOGGER.info("Send push message: '#{msg}' to '#{target_id}'")

      @@bot.send_message(target_id.to_i, msg, false, nil)
      return 200
    rescue RestClient::BadRequest, RestClient::Forbidden, RestClient::NotFound => e
      LOGGER.error("Failed to request to Discord: #{e}")
      return e.http_code
    rescue => e
      LOGGER.error("Failed to request to Discord: #{e}")
      return 500
    end
  end
end
