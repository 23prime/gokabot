require 'discordrb'
require 'dotenv/load'

require_relative '../log_config'

module Discord
  class Push
    include LogConfig

    def initialize
      @logger = @@logger.clone
      @logger.progname = self.class.to_s
    end

    def send_message(msg)
      bot = Discordrb::Bot.new token: ENV['DISCORD_BOT_TOKEN']
      bot.send_message(ENV['DISCORD_TARGET_CHANNEL_ID'].to_i, msg, false, nil)
      @logger.info("Send a message '#{msg}' to Discord")
      return true
    rescue => e
      @logger.error(e)
      return false
    end
  end
end
