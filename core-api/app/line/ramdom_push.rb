require_relative '../src/gokabou/gen_msg'
require_relative '../src/gokabou/update_db'
require_relative './push'

module Line
  class RamdomPush < Push
    def initialize
      @logger = @@logger.clone
      @logger.progname = self.class.to_s
      super()
    end

    def send_push_msg(target)
      msg = Gokabou::GenMsg.new(Gokabou::UpdateDB.new.all_sentences).sample
      return super(msg, target)
    end
  end
end
