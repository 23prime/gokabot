class Gokabou
  @@version = '1.0.0'
  @@help = File.open('./docs/help', 'r').read
  @@omikuji = File.open('./docs/omikuji', 'r').read.split("\n")
  @@tweets = File.open('./docs/gokabou_tweets', 'r').read.split("\n")
  @@deads = [
    'いや、死なないよ。',
    '死ぬ〜〜〜〜〜ｗ', 
    '死んだｗ',
    'おいおい…',
    '死んダダダダダダーン',
    '人に死ねなんて言葉使うな😡',
    '死ぬまで死なないよ',
    '死ねのバーゲンセールかよ',
    'きみ、死ねしか言えないの？',
    'そっちからリプ送ってきて死ねっつうな！死ね！しねしねこうせん！💨',
    'いやでｗｗｗいやでござるｗｗｗ'
  ]
  
  def answer(msg)
    case msg
    when /死ね|死んで/
      return @@deads.sample
    when /行く/
      return '俺もイク！ｗ'
    when /^gokabot[[:blank:]]+(-v|--version)$/
      return @@version
    when /^gokabot[[:blank:]]+(-h|--help)$/
      return @@help
    when /^ごかぼっと$|^gokabot$/
      return 'なんですか？'
    when /^ごかぼう$|^gokabou$|^ヒゲ$|^ひげ$/
      return @@tweets.sample
    when /^おみくじ$/
      return @@omikuji.sample
    when /^たけのこ(君|くん|さん|)$/
      return 'たけのこ君ｐｒｐｒ'
    when /^ぬるぽ$/
      return 'ｶﾞｯ'
    else
      return nil
    end
  end
end