require_relative 'anime'
require_relative 'convert'

module Season
  module_function

  SEASONS = %w[winter spring summer fall]

  def get_season(month)
    return SEASONS[(month - 1) / 3]
  end

  def next_season(season)
    idx = (SEASONS.index(season) + 1) % 4
    return SEASONS[idx]
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

    def next_season
      year = @year
      year += 1 if @season == 'fall'
      season = Season.next_season(@season)
      return year, season
    end

    def select_answer(msg)
      day = converts(msg)

      case day
      when /^all|今期#{ANIME_OF}/i
        return @anime.get_animes(@year, @season, day, true, false)
      when /^今期の(オススメ|おすすめ)$/i
        return @anime.get_animes(@year, @season, day, true, true)
      when /^next|来期#{ANIME_OF}/i
        year, season = next_season
        return @anime.get_animes(year, season, day, true, false)
      when /^来期の(オススメ|おすすめ)$/i
        year, season = next_season
        return @anime.get_animes(year, season, day, true, true)
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
      return ans
    end
  end
end
