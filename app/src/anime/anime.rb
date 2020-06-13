require 'active_record'
require 'dotenv/load'

module Anime
  class Anime < ActiveRecord::Base
    self.table_name = 'gokabot.animes'
  end

  class GetAnimes
    attr_reader :con

    SORT = "
      ORDER BY
      CASE day
        WHEN 'Sun' THEN 0
        WHEN 'Mon' THEN 1
        WHEN 'Tue' THEN 2
        WHEN 'Wed' THEN 3
        WHEN 'Thu' THEN 4
        WHEN 'Fri' THEN 5
        WHEN 'Sat' THEN 6
        ELSE 7
      END,
      time
    "

    def initialize
      Anime.establish_connection(
        ENV['DATABASE_URL']
      )
    end

    def get_animes(year, season, day, all, rcm)
      query = mk_query(year, season, day, all, rcm)
      animes = []

      Anime.connection_pool.with_connection do |con|
        animes = con.select_all(query).to_a
      end

      return show_animes(animes, all) unless animes.empty?
      return 'ありませ〜んｗｗｗｗ' if rcm
      return '早漏かよｗ'
    end

    private

    # all: Bool <- All of the season or not
    # rcm: Bool <- Only recommended or not
    def mk_query(year, season, day, all, rcm)
      colmuns = 'time, title, station'
      colmuns = "day, #{colmuns}" if all

      default_select = "
        SELECT #{colmuns}
          FROM gokabot.animes
      "
      add_conds = ''
      add_conds = "#{add_conds} AND day = '#{day}'" unless all
      add_conds = "#{add_conds} AND recommend" if rcm

      query = "
        #{default_select}
        WHERE year = #{year}
          AND season = '#{season}'
          #{add_conds}
        #{SORT};
      "

      return query
    end

    def show_animes(animes, all)
      ans = ''

      animes.each do |anime|
        time = anime['time']
        station = anime['station']
        title = anime['title']
        day = anime['day']
        ans << "#{day}, " if all
        ans << "#{time}, #{station}, #{title}\n"
      end

      ans.strip!

      return ans
    end
  end
end
