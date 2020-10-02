require 'discordrb'
require 'dotenv/load'

require './app/log_config'

class PushDiscord
  include LogConfig

  @@logger = @@logger.clone
  @@logger.progname = 'Push'

  def self.send_message(msg)
    bot = Discordrb::Bot.new token: ENV['DISCORD_BOT_TOKEN']
    bot.send_message(ENV['DISCORD_TARGET_CHANNEL_ID'].to_i, msg, false, nil)
    @@logger.info("Send a message '#{msg}' to Discord")
    return true
  rescue => e
    @@logger.error(e)
    return false
  end
end
