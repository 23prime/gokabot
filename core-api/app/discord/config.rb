require 'discordrb'
require 'line/bot'

module Discord
  module Config
    @@bot = Discordrb::Bot.new token: ENV['DISCORD_BOT_TOKEN']
  end
end
