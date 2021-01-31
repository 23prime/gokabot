require 'dotenv/load'

require_relative '../log_config'
require_relative '../core/gokabou/gen_msg'
require_relative 'push'

module Discord
  class RamdomPush
    include LogConfig

    def initialize
      @logger = @@logger.clone
      @logger.progname = self.class.to_s
    end

    def send_message(target_id)
      msg = Gokabou::GenMsg.new.sample
      return Push.new.send_message(msg, target_id)
    end
  end
end
