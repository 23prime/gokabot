require_relative './game_results.rb'
require_relative './get_data.rb'

module BaseballNews
  class AnswerFormatter
    class << self
      def day_all_game(msg)
        return unless msg =~ /野球\Z/
        date = make_date msg.gsub(/野球/, '')
        return unless date
        res = init(date).all_game
        day_res_to_s res
      end

      def team_game(teamnum)
        res = (init make_date).team_results[teamnum]
        return team_res_to_s res
      end

      def make_date(msg = '今日の')
        date = Date.today.strftime('%Y%m%d').to_i
        case msg
        when '今日の', ''
          return date
        when '昨日の'
          return date - 1
        when '明日の'
          return date + 1
        else
          return false
        end
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
