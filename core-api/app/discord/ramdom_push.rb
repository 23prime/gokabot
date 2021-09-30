require 'dotenv/load'

require_relative '../log_config'
require_relative '../core/gokabou/gen_msg'
require_relative 'push'

module Discord
  class RamdomPush
    def send_message(target_id)
      msg = Gokabou::GenMsg.new.sample
      return Push.new.send_message(msg, target_id)
    end
  end
end
