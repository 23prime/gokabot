class Denippi
  @@monyo_cnt = 0

  def monyo_chk(msg)
    return 'そ' if msg =~ /^(ね|寝)$/
    return %w[の こ].sample if msg =~ /^うん$/
    @@monyo_cnt += 1
    return [*'ぁ'..'ん'].sample if msg =~ /^\p{Hiragana}$/ && @@monyo_cnt == 2
    return [*'ァ'..'ン'].sample if msg =~ /^\p{Katakana}$/ && @@monyo_cnt == 2
  end

  def answer(*msg_data)
    msg = msg_data[0]
    if @@monyo_cnt >= 2 || @@monyo_cnt.nil?
      @@monyo_cnt = 0
    end

    monyo_chk(msg) if msg =~ /^([ぁ-ん]|[ァ-ン]|寝)$|^うん$/
  end
end
