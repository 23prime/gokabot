# coding:  utf-8

def nyokki(msg,rep_text)
  $nyokki_stat += 1
  if msg =~ /(ニョッキ|にょっき|ﾆｮｯｷ)/
    msg.tr!("０-９", "0-9").delete!("^0-9")
    if msg.to_i == $nyokki_stat
      return
    else
      rep_text = "負けｗｗｗ"
      $nyokki_stat = 0
    end
  else 
    rep_text = "負けｗ"
    $nyokki_stat = 0
end
