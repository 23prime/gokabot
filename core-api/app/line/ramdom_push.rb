require_relative '../core/gokabou/gen_msg'
require_relative '../db/gokabous_dao'
require_relative 'push'

module Line
  class RamdomPush < Push
    def initialize
      @logger = @@logger.clone
      @logger.progname = self.class.to_s
      super()
    end

    def send_push_msg(target)
      msg = Gokabou::GenMsg.new.sample
      return super(msg, target)
    end
  end
end
