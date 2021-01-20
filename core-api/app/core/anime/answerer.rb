require_relative '../../db/animes_dao'
require_relative 'convert'

module Season
  module_function

  SEASONS = %w[winter spring summer fall]

  def get_season(month)
    return SEASONS[(month - 1) / 3]
  end

  def get_next_season(season)
    idx = (SEASONS.index(season) + 1) % 4
    return SEASONS[idx]
  end
end

module Anime
  class Answerer
    WDAYS = %w[Sun Mon Tue Wed Thu Fri Sat]

    def initialize
      now = Time.now.localtime('+05:00')
      @year = now.year
      @season = Season.get_season(now.month)
      @animes_dao = AnimesDao.new
      @converts = [
        WeekDay.new,
        Day.new(WDAYS, now.wday),
        Recommend.new(WDAYS, now.wday)
      ]
    end

    def answer(*msg_data)
      initialize
      msg = msg_data[0]
      return select_answer(msg)
    end

    private

    def to_next_season
      @year += 1 if @season == 'fall'
      @season = Season.get_next_season(@season)
    end

    def select_answer(msg)
      day = convert(msg)

      case day
      when /^all|今期#{ANIME_OF}/i
        return format_animes(
          @animes_dao.select_season_animes(@year, @season),
          is_all: true,
          only_rcm: false
        )
      when /^今期の(オススメ|おすすめ)$/i
        return format_animes(
          @animes_dao.select_season_recommend_animes(@year, @season),
          is_all: true,
          only_rcm: true
        )
      when /^next|来期#{ANIME_OF}/i
        to_next_season
        return format_animes(
          @animes_dao.select_season_animes(@year, @season),
          is_all: true,
          only_rcm: false
        )
      when /^来期の(オススメ|おすすめ)$/i
        to_next_season
        return format_animes(
          @animes_dao.select_season_recommend_animes(@year, @season),
          is_all: true,
          only_rcm: true
        )
      when WEEK
        return format_animes(
          @animes_dao.select_day_animes(@year, @season, day),
          is_all: false,
          only_rcm: false
        )
      when WEEK_RCM
        day.capitalize!
        return format_animes(
          @animes_dao.select_day_recommend_animes(@year, @season, day),
          is_all: false,
          only_rcm: true
        )
      else
        return nil
      end
    end

    def convert(msg)
      @converts.each do |cvt|
        ans = cvt.convert(msg)
        unless ans.nil?
          return ans
        end
      end
      return msg
    end

    def format_animes(animes, is_all: true, only_rcm: true)
      if animes.empty?
        return 'ありませ〜んｗｗｗｗ' if only_rcm
        return '早漏かよｗ'
      end

      animes = sort_animes(animes, is_all)

      ans = ''

      animes.each do |anime|
        ans << "#{anime.day}, " if is_all
        ans << "#{anime.time}, #{anime.station}, #{anime.title}\n"
      end

      ans.strip!

      return ans
    end

    def sort_animes(animes, is_all)
      animes = animes.sort_by(&:time)
      animes = animes.sort_by { |a| day_to_int(a.day) } if is_all
      return animes
    end

    def day_to_int(day)
      result = WDAYS.index(day)
      result = -1 if result.nil?
      return result
    end
  end
end
