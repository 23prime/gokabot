#coding : utf-8

class Denippi
  @@monyo_cnt = 0

  def monyo_chk(msg)
    if @@monyo_cnt >= 2 || @@monyo_cnt.nil?
      @@monyo_cnt = 0
    end
    return "そ" if msg =~/^(ね|寝)$/
    @@monyo_cnt += 1
    return [*"ぁ".."ん"].sample if msg =~ /^\p{Hiragana}$/ && @@monyo_cnt == 2
    return [*"ァ".."ン"].sample if msg =~ /^\p{Katakana}$/ && @@monyo_cnt == 2
  end

  def answer(msg)
    if msg =~ /^([ぁ-ん]|[ァ-ン]|寝)$/
      monyo_chk(msg)
    else
      nil
    end
  end

end

