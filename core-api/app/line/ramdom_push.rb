require_relative '../core/gokabou/gen_msg'
require_relative 'push'

module Line
  class RamdomPush
    include LogConfig

    def initialize
      @logger = @@logger.clone
      @logger.progname = self.class.to_s
    end

    def send_msg(target)
      msg = Gokabou::GenMsg.new.sample
      return Push.new.send_msg(msg, target)
    end
  end
end
