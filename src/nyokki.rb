# coding:  utf-8
class Nyokki
  @@nyokki_stat = 0

  def self.nyokki(msg)
    @@nyokki_stat += 1
    if msg =~ /(ニョッキ|にょっき|ﾆｮｯｷ)/
      msg.tr!("０-９", "0-9")
      msg.delete!("^0-9")
      return '' if msg.to_i == @@nyokki_stat
    end
    @@nyokki_stat = 0
    "負けｗｗｗ"
  end

  def self.stat
    @@nyokki_stat
  end

end

