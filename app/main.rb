# coding: utf-8
require 'sinatra'
require 'line/bot'
require './app/imports.rb'


$version = '1.0.0'
$help = File.open('./docs/help', 'r').read
$all_animes = File.open('./docs/18summer.yaml', 'r').read
$omikuji = File.open('./docs/omikuji', 'r').read.split("\n")
$gokabou = File.open('./docs/gokabou_tweets', 'r').read.split("\n")
$deads = [
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
$tenki = Weather.new()
$web_dict = WebDict::Answerer.new()


def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end


# Make reply for each case.
def reply(event)
  msg = event.message['text']
  mk_reply(msg)
end


def mk_reply(msg) 
  rep_text  = ''
  msg       = Anime.convert(msg)
  msg_split = msg.split(/[[:blank:]]+/)
  msg0      = msg_split[0]
  wdays     = %w[Sun Mon Tue Wed Thu Fri Sat]
  d         = Time.now.localtime("+05:00").wday

  if Nyokki.stat > 0 || msg =~ /(1|１)(ニョッキ|にょっき|ﾆｮｯｷ)/
    rep_text = Nyokki.nyokki(msg)
  elsif ans = $web_dict.answer(msg)
    rep_text = ans
  elsif ans = $tenki.weather(msg)
    rep_text = ans
  else
    case msg
    when /^All$|#{Anime::WEEK}/i
      rep_text = Anime.filter($all_animes, msg)
    when /死ね|死んで/
      rep_text = $deads.sample
    when /行く/
      rep_text = '俺もイク！ｗ'
    when /^([ぁ-ん]|[ァ-ン])$/
      rep_text = Denippi.monyo_chk(msg)
    when /鳩|ゆかり|はと/
      rep_text = Pigeons.mail
    when /^gokabot[[:blank:]]+(-v|--version)$/
      rep_text = $version
    when /^gokabot[[:blank:]]+(-h|--help)$/
      rep_text = $help
    when /^ごかぼっと$|^gokabot$/
      rep_text = 'なんですか？'
    when /^ごかぼう$|^gokabou$|^ヒゲ$|^ひげ$/
      rep_text = $gokabou.sample
    when /^昨日(のアニメ|)$|^yesterday$/i
      rep_text = Anime.filter($all_animes, wdays[d - 1])
    when /^今日(のアニメ|)$|^today$/i
      rep_text = Anime.filter($all_animes, wdays[d])
    when /^明日(のアニメ|)$|^tomorrow$/i
      rep_text = Anime.filter($all_animes, wdays[(d + 1) % 7])
    when /^おみくじ$/
      rep_text = $omikuji.sample
    when /^たけのこ(君|くん|さん|)$/
      rep_text = 'たけのこ君ｐｒｐｒ'
    when /^ぬるぽ$/
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
