require 'yaml'
require_relative 'anime'
require_relative 'convert'

module Season
  module_function

  def get_season(month)
    return 'winter' if [1, 2, 3].include?(month)
    return 'spring' if [4, 5, 6].include?(month)
    return 'summer' if [7, 8, 9].include?(month)
    return 'fall' if [10, 11, 12].include?(month)
  end
end

module Anime
  class Answerer
    @@now = Time.now.localtime('+05:00')
    @@today = @@now.wday

    def initialize
      month = @@now.month
      @year = @@now.year
      season = Season.get_season(month)
      next_season = Season.get_season((month + 3) % 12)

      @animes = Animes.new(YAML)
      @animes.select_term(@year, season)
      @animes.sort_animes

      year2 = @year
      year2 += 1 if @season == 'fall'
      @next_animes = Animes.new(YAML)
      @next_animes.select_term(year2, next_season)
      @next_animes.sort_animes
    end

    YAML = YAML.safe_load(File.open('./docs/animes.yaml', 'r').read)
    WDAYS = %w[Sun Mon Tue Wed Thu Fri Sat]
    CONVERTS = [
      WeekDay.new,
      Day.new(WDAYS, @@today),
      Recommend.new(WDAYS, @@today)
    ]

    def converts(msg)
      CONVERTS.each do |cvt|
        ans = cvt.convert(msg)
        unless ans.nil?
          return ans
          break
        end
      end
      return msg
    end

    def select_answer(msg)
      day = converts(msg)

      case day
      when /^all|今期#{ANIME_OF}/i
        return @animes.print_animes(0)
      when /^今期の(オススメ|おすすめ)$/i
        @animes.select_rcm
        return @animes.print_animes(0)
      when /^next|来期#{ANIME_OF}/i
        return @next_animes.print_animes(0) unless @next_animes.empty?
        return '早漏かよｗ'
      when /^来期の(オススメ|おすすめ)$/i
        @next_animes.select_rcm
        return @next_animes.print_animes(0) unless @next_animes.empty?
        return '早漏かよｗ'
      when WEEK
        @animes.select_day(day)
        return @animes.print_animes(1)
      when WEEK_RCM
        day = day.capitalize
        @animes.select_day(day)
        @animes.select_rcm
        return @animes.print_animes(1) unless @animes.empty?
        return 'ありませ〜んｗｗｗｗ'
      else
        return nil
      end
    end

    def answer(msg)
      ans = select_answer(msg)
      initialize
      return ans
    end
  end
end
