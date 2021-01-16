class Nyokki
  @@nyokki_stat = 0

  def nyokki(msg)
    @@nyokki_stat += 1
    if msg =~ /(ニョッキ|にょっき|ﾆｮｯｷ)/
      msg.tr!('０-９', '0-9')
      msg.delete!('^0-9')
      return nil if msg.to_i == @@nyokki_stat
    end
    @@nyokki_stat = 0
    return '負けｗｗｗ'
  end

  def answer(*msg_data)
    msg = msg_data[0]

    return nyokki(msg) if @@nyokki_stat.positive? || msg =~ /(1|１)(にょっき|ニョッキ|ﾆｮｯｷ)/
    return nil
  end
end
