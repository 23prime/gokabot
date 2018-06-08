# coding:  utf-8

def nyokki(msg)
  $nyokki_stat += 1
  if msg =~ /(ニョッキ|にょっき|ﾆｮｯｷ)/
    msg.tr!("０-９", "0-9")
    msg.delete!("^0-9")
    if msg.to_i == $nyokki_stat
      return
    else
      $nyokki_stat = 0
      "負けｗｗｗ"
    end
  else 
    $nyokki_stat = 0
     "負けｗ"
  end
end
