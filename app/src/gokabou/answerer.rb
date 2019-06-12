require_relative './gen_msg.rb'

module Gokabou
  class Answerer
    def initialize
      @version = '1.0.0'
      @help = File.open('./docs/help', 'r').read
      @omikuji = File.open('./docs/omikuji', 'r').read.split("\n")

      @deads = [
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
        'いやでｗｗｗいやでござるｗｗｗ',
        'し、しにたくないでおぢゃる〜ｗｗｗ'
      ]

      @new_years = [
        'あけおめでつｗ',
        'Happy New Year でござるｗｗ',
        'は？',
        'ことよろチクビｗ',
        'あけおまんこｗｗｗｗｗｗ開帳くぱぁｗｗｗｗｗｗ',
        '今年はヒゲを剃りたい'
      ]

      @d = Time.now
      @month = @d.month
      @day = @d.day

      @gkb = Gokabou.new
    end

    def answer(*msg_data)
      msg = msg_data[0]

      case msg
      when /\Aこん(|です)(|ｗ|w)\Z/i
        return 'こん'
      when /死ね|死んで/
        return @deads.sample
      when /行く/
        return '俺もイク！ｗ'
      when /\Agokabot[[:blank:]]+(-v|--version)\Z/
        return @version
      when /\Agokabot[[:blank:]]+(-h|--help)\Z/
        return @help
      when /ごかぼっと|gokabot|ごかぼう|gokabou|\Aヒゲ\Z|\Aひげ\Z/
        return @gkb.gen_ans
      when /\Aおみくじ\Z/
        return @omikuji.sample
      when /たけのこ(君|くん|さん|ちゃん|)/
        return 'たけのこ君ｐｒｐｒ'
      when /\Aぬるぽ\Z/
        return 'ｶﾞｯ'
      when /あけ|明け|おめ|こん|おは|happy|new|year|2019/i
        return @new_years.sample if @month == 1 && @day == 1
      when /\Aうん(こ|ち)\Z|\Aウン(コ|チ)\Z|\A💩\Z/
        return 'ウンコマンだ～～‼️‼️‼️‼️‼️‼️‼️‼️‼️‼'
      else
        return nil
      end
    end
  end
end
