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
      @season = Season.get_season(month)
      @next_season = Season.get_season((month + 3) % 12)
      @year2 = @year
      @year2 += 1 if @season == 'fall'
      @anime = GetAnimes.new
    end

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
        end
      end
      return msg
    end

    def select_answer(msg)
      day = converts(msg)

      case day
      when /^all|今期#{ANIME_OF}/i
        return @anime.get_animes(@year, @season, day, true, false)
      when /^今期の(オススメ|おすすめ)$/i
        return @anime.get_animes(@year, @season, day, true, true)
      when /^next|来期#{ANIME_OF}/i
        return @anime.get_animes(@year2, @next_season, day, true, false)
      when /^来期の(オススメ|おすすめ)$/i
        return @anime.get_animes(@year2, @next_season, day, true, true)
      when WEEK
        return @anime.get_animes(@year, @season, day, false, false)
      when WEEK_RCM
        day.capitalize!
        return @anime.get_animes(@year, @season, day, false, true)
      else
        return nil
      end
    end

    def answer(*msg_data)
      msg = msg_data[0]
      ans = select_answer(msg)
      # initialize
      return ans
    end
  end
end
