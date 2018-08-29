Time.now.localtime("+05:00").wday

  if Nyokki.stat > 0 || msg =~ /(1|１)(ニョッキ|にょっき|ﾆｮｯｷ)/
    rep_text = Nyokki.nyokki(msg)
  elsif ans = $web_dict.answer(msg)
    rep_text = ans
  elsif ['All', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].include?(msg)
    rep_text = Anime.filter($all_animes, msg)
  elsif msg =~ /死ね|死んで/
    rep_text = $deads.sample
  elsif msg =~ /行く/
    rep_text = '俺もイク！ｗ'
  elsif msg =~/^.$/
    rep_text = Denippi.monyo_chk(msg)
  elsif
    case msg0
    when '天気', '今日の天気', '明日の天気'
      rep_text = Weather.weather(msg0, msg_split[1])
    end
  else
    case msg
    when 'gokabot -v', 'gokabot --version'
      rep_text = $version
    when 'gokabot -h', 'gokabot --help'
      rep_text = $help
    when 'ごかぼっと', 'gokabot'
      rep_text = 'なんですか？'
    when 'ごかぼう', 'gokabou', 'ヒゲ', 'ひげ'
      rep_text = $gokabou.sample
    when '昨日のアニメ', '昨日', 'yesterday'
      rep_text = Anime.filter($all_animes, wdays[d - 1])
    when '今日のアニメ', '今日', 'today'
      rep_text = Anime.filter($all_animes, wdays[d])
    when '明日のアニメ', '明日', 'tomorrow'
      rep_text = Anime.filter($all_animes, wdays[(d + 1) % 7])
    when 'おみくじ'
      rep_text = $omikuji.sample
    when 'たけのこ'
      rep_text = 'たけのこ君ｐｒｐｒ'
    when 'ぬるぽ'
      rep_text = 'ｶﾞｯ'
    end
  end

  reply = {
    type: 'text',
    text: rep_text
  }
  return reply
end


# Execute.
post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        client.reply_message(event['replyToken'], reply(event))
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open('content')
        tf.write(response.body)
      end
    end
  }

  'OK'
end
