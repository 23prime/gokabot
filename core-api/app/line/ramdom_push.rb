require_relative '../core/gokabou/gen_msg'
require_relative 'push'

module Line
  class RamdomPush
    def send_msg(target_id)
      msg = Gokabou::GenMsg.new.sample
      return Push.new.send_msg(msg, target_id)
    end
  end
end
