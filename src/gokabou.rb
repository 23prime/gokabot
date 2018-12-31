$VERSION = '1.0.0'
$HELP = File.open('./docs/help', 'r').read
$OMIKUJI = File.open('./docs/omikuji', 'r').read.split("\n")
$TWEETS = File.open('./docs/gokabou_tweets', 'r').read.split("\n")
$DEADS = [
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
$NEW_YEARS = [
  'あけおめでつｗ',
  'Happy New Year でござるｗｗ',
  'は？',
  'ことよろチクビｗ',
  'あけおまんこｗｗｗｗｗｗ開帳くぱぁｗｗｗｗｗｗ',
  '今年はヒゲを剃りたい'
]

class Gokabou
  def answer(msg)
    case msg
    when /死ね|死んで/
      return $DEADS.sample
    when /行く/
      return '俺もイク！ｗ'
    when /\Agokabot[[:blank:]]+(-v|--version)\Z/
      return $VERSION
    when /\Agokabot[[:blank:]]+(-h|--help)\Z/
      return $HELP
    when /ごかぼっと|gokabot|ごかぼう|gokabou|\Aヒゲ\Z|\Aひげ\Z/
      return $TWEETS.sample
    when /\Aおみくじ\Z/
      return $OMIKUJI.sample
    when /たけのこ(君|くん|さん|ちゃん|)/
      return 'たけのこ君ｐｒｐｒ'
    when /\Aぬるぽ\Z/
      return 'ｶﾞｯ'
    when /あけ|明け|おめ|こん|おは|happy|new|year|2019/i
      return $NEW_YEARS.sample
    else
      return nil
    end
  end
end
