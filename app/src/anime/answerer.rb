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
    WDAYS = %w[Sun Mon Tue Wed Thu Fri Sat]

    def initialize
      now = Time.now.localtime('+05:00')
      today = now.wday
      month = now.month
      @year = now.year
      @season = Season.get_season(month)
      @anime = GetAnimes.new
      @converts = [
        WeekDay.new,
        Day.new(WDAYS, today),
        Recommend.new(WDAYS, today)
      ]
    end

    def answer(*msg_data)
      initialize
      msg = msg_data[0]
      ans = select_answer(msg)
      return ans
    end

    private

    def convert(msg)
      @converts.each do |cvt|
        ans = cvt.convert(msg)
        unless ans.nil?
          return ans
        end
      end
      return msg
    end

    def next_season
      @year += 1 if @season == 'fall'
      @season = Season.next_season(@season)
    end

    def select_answer(msg)
      day = convert(msg)

      case day
      when /^all|今期#{ANIME_OF}/i
        return @anime.get_animes(@year, @season, day, true, false)
      when /^今期の(オススメ|おすすめ)$/i
        return @anime.get_animes(@year, @season, day, true, true)
      when /^next|来期#{ANIME_OF}/i
        next_season
        return @anime.get_animes(@year, @season, day, true, false)
      when /^来期の(オススメ|おすすめ)$/i
        next_season
        return @anime.get_animes(@year, @season, day, true, true)
      when WEEK
        return @anime.get_animes(@year, @season, day, false, false)
      when WEEK_RCM
        day.capitalize!
        return @anime.get_animes(@year, @season, day, false, true)
      else
        return nil
      end
    end
  end
end
