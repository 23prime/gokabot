require_relative './answer_formatter.rb'

module BaseballNews
  class Answerer
    def answer(*arg)
      msg = arg[0]
      return unless msg =~ /\A野球(|速報)/
      msg_a = msg.split
      return AnswerFormatter.day_all_game if msg_a[1].nil?
      teamnum = fetcher msg_a.last
      date = AnswerFormatter.make_date teamnum, msg_a[1]
      return unless date
      return AnswerFormatter.day_all_game date if teamnum == -1
      return AnswerFormatter.team_game teamnum, date
    end

    def fetcher(text)
      @words = [
        /^(巨|ジャイアンツ|読売|G|Ｇ|兎)/i,
        /^(東京ヤクルト|ヤ|スワローズ|S|Ｓ|燕)/i,
        /^(横浜|De|Ｄｅ|DB|ベイスターズ|ＤＢ|星)/i,
        /^(中|ドラゴンズ|D|Ｄ|竜)/i,
        /^(タイガース|虎|神|T|阪|Ｔ)/i,
        /^(広|東洋|カープ|C|Ｃ|鯉)/i,
        /^(埼玉|西|ライオンズ|L|Ｌ|猫)/i,
        /^(日|ハム|ファイターズ|F|Ｆ|公)/i,
        /^(千葉|ロ|マリーンズ|M|Ｍ|鴎)/i,
        /^(オリックス|オ|バファローズ|B|Ｂ|檻)/i,
        /^(ソ|ホークス|H|Ｈ|福岡|SB|ＳＢ|鷹)/i,
        /^(楽|東北|E|イーグルス|鷲|Ｅ)/i
      ]
      @words.each_with_index { |w, i| return i if text =~ w }
      return -1
    end
  end
end
