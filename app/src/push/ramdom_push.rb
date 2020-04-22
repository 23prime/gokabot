require './app/src/gokabou/gen_msg'
require './app/src/gokabou/update_db'
require_relative './push'

class RamdomPush < Push
  def self.send_push_msg(target)
    msg = Gokabou::GenMsg.new(Gokabou::UpdateDB.new.all_sentences).sample
    return super(msg, target)
  end
end
