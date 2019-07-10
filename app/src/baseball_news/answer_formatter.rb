require 'zen_to_i'
require_relative './game_results.rb'
require_relative './get_data.rb'

module BaseballNews
  class AnswerFormatter
    class << self
      def day_all_game(date = make_date(0))
        res = (init date).all_game
        day_res_to_s res
      end

      def team_game(teamnum, date)
        res = (init date).make_team_result
        return team_res_to_s res[teamnum]
      end

      def make_date(teamnum, msg = '今日')
        msg = msg.zen_to_i
        if msg =~ /^\d{1,2}月\d{1,2}日$/
          return Date.today.strftime('%Y') +
                 msg.split(/月|日/).map { |d|
                   format('%02d', d)
                 }.join
        end
        dif = { '昨日' => -1, '今日' => 0, '明日' => 1 }[msg]
        return false if dif.nil? && teamnum == -1
        dif = 0 if dif.nil?
        date = Date.today.strftime('%Y%m%d').to_i
        return (date + dif).to_s
      end

      def team_res_to_s(res)
        return '試合はありません' if res.nil?
        text = ''
        text += res[:result] + "\n"
        text += res[:fteam] + ' - ' + res[:steam] + "\n"
        text += res[:fscore] + ' - ' + res[:sscore] + "\n"
        return text
      end

      def day_res_to_s(res)
        return '試合はありません' if res == []
        text = ''
        res.each { |r|
          text += r[:result] + "\n"
          text += r[:team][0] + ' - ' + r[:team][1] + "\n"
          text += r[:score][0] + ' - ' + r[:score][1] + "\n\n"
        }
        return text
      end

      def init(date)
        return GameResults.new GetData.scrape_page date
      end
    end
  end
end
