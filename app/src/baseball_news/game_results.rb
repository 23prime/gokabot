module BaseballNews
  class GameResults
    attr_reader :team_results, :all_game
    def initialize(scraped_data)
      results = scraped_data[0]
      teams = scraped_data[1]
      scores = scraped_data[2]
      make_result_pairs results, teams, scores
      make_team_result
    end

    def make_result_pairs(results, teams, scores)
      @all_game = results.map.with_index do |r, i|
        {
          result: r,
          team: [teams[2 * i], teams[2 * i + 1]],
          score: [scores[2 * i], scores[2 * i + 1]]
        }
      end
    end

    def make_team_result
      @team_results = []
      @all_game.each { |game|
        2.times { |i|
          tind = team_to_i(game[:team][i])
          @team_results[tind] = {
            result: game[:result],
            fteam: game[:team][0],
            steam: game[:team][1],
            fscore: game[:score][0],
            sscore: game[:score][1]
          }
        }
      }
    end

    def team_to_i(name)
      {
        '巨人' => 0,
        'ヤクルト' => 1,
        'ＤｅＮＡ' => 2,
        '中日' => 3,
        '阪神' => 4,
        '広島' => 5,
        '西武' => 6,
        '日本ハム' => 7,
        'ロッテ' => 8,
        'オリックス' => 9,
        'ソフトバンク' => 10,
        '楽天' => 11
      }[name]
    end
  end
end
