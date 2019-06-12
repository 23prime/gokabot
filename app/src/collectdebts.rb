class CollectDebts
  def initialize
    @collect_msg = [
      "たけのこは借金返さないゴミクズ糞ニート\nしかもネカマ",
      'たけのこ借金返してよおおおおおおおおお(´༎ຶོρ༎ຶོ`)'
    ]
  end

  def takenoko?(msg_data)
    return msg_data[1] == ENV['TAKENOKO_USER_ID'] || (msg_data[2] =~ /たけのこ|このけた/)
  end

  def answer(*msg_data)
    return @collect_msg.sample if takenoko?(msg_data)
  end
end
