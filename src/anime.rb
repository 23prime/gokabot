require 'yaml'

module Anime
  class Animes < Array
    attr_reader :animes

    def initialize(array)
      @animes = array
    end

    def +(a2)
      a2 = a2.animes()
      return Animes.new(@animes + a2)
    end

    def empty?
      return @animes.empty?
    end

    def select_term(year, season)
      year = year.to_s
      selected = @animes.select { |anime|
          anime['year'] == year && anime['season'] == season
        }
      return Animes.new(selected)
    end

    def select_day(day)
      selected = @animes.select { |anime| anime['day'] == day }
      return Animes.new(selected)
    end

    def select_rcm
      selected = @animes.select { |anime| anime['recommend'] }
      return Animes.new(selected)
    end

    def sort_by_time
      selected = @animes.sort_by { |anime| anime['time'] }
      return Animes.new(selected)
    end

    def sort_animes
      days = %w[Sun Mon Tue Wed Thu Fri Sat]
      ans = Animes.new([])
      days.each do |day|
        ans += select_day(day).sort_by_time()
      end
      return ans
    end

    def print_animes(n)
      ans = ''
      @animes.each do |anime|
        time = anime['time']
        station = anime['station']
        title = anime['title']
        day = anime['day']
        ans << "#{day}, " if n.zero?
        ans << "#{time}, #{station}, #{title}\n"
      end
      ans.strip!
      return ans
    end
  end

  class Answerer
    module Season
      module_function

      def get_season(month)
        return 'winter' if [1, 2, 3].include?(month)
        return 'spring' if [4, 5, 6].include?(month)
        return 'summer' if [7, 8, 9].include?(month)
        return 'fall' if [10, 11, 12].include?(month)
      end
    end

    @@yaml = YAML.safe_load(File.open('./docs/animes.yaml', 'r').read)
    @@animes = Animes.new(@@yaml)
    @@d = Time.now.localtime('+05:00')
    @@year = @@d.year
    @@month = @@d.month
    @@season = Season.get_season(@@month)
    @@next_season = Season.get_season((@@month + 3) % 12)

    ANIME_OF = /(のアニメ|)$/
    RECOMMEND = /(おすすめ|オススメ)$/
    DAY_ANIME_OF = /曜(日|)#{ANIME_OF}/
    DAY = /(day|)$/i
    WEEK = /^Sun$|^Mon$|^Tue$|^Wed$|^Thu$|^Fri$|^Sat$/
    WEEK_RCM = /^sun$|^mon$|^tue$|^wed$|^thu$|^fri$|^sat$/

    def convert(msg)
      wdays = %w[Sun Mon Tue Wed Thu Fri Sat]
      today = @@d.wday

      case msg
      when /^sun#{DAY}|^日#{DAY_ANIME_OF}/i
        return 'Sun'
      when /^mon#{DAY}|^月#{DAY_ANIME_OF}/i
        return 'Mon'
      when /^tue(sday|)$|^火#{DAY_ANIME_OF}/i
        return 'Tue'
      when /^wed(nesday|)$|^水#{DAY_ANIME_OF}/i
        return 'Wed'
      when /^thu(rsday|)$|^木#{DAY_ANIME_OF}/i
        return 'Thu'
      when /^fri#{DAY}|^金#{DAY_ANIME_OF}/i
        return 'Fri'
      when /^sat#{DAY}|^土#{DAY_ANIME_OF}/i
        return 'Sat'
      when /^今日#{ANIME_OF}|^today$/i
        return wdays[today]
      when /^昨日#{ANIME_OF}|^yesterday$/i
        return wdays[today - 1]
      when /^明日#{ANIME_OF}|^tomorrow$/i
        return wdays[(today + 1) % 7]
      when /^(今日の|)#{RECOMMEND}/i
        return wdays[today].downcase
      when /^昨日の#{RECOMMEND}/i
        return wdays[today - 1].downcase
      when /^明日の#{RECOMMEND}/i
        return wdays[(today + 1) % 7].downcase
      else
        return msg
      end
    end

    def answer(msg)
      day = convert(msg)
      animes = @@animes.select_term(@@year, @@season).sort_animes()
      year2 = @@year
      year2 += 1 if @@season == 'fall'
      next_animes = @@animes.select_term(year2, @@next_season).sort_animes()

      case day
      when /^all|今期#{ANIME_OF}/i
        return animes.print_animes(0)
      when /^今期の(オススメ|おすすめ)$/i
        return animes.select_rcm().print_animes(0)
      when /^next|来期#{ANIME_OF}/i
        return next_animes.print_animes(0)
      when /^来期の(オススメ|おすすめ)$/i
        return next_animes.select_rcm().print_animes(0)
      when WEEK
        return animes.select_day(day).print_animes(1)
      when WEEK_RCM
        day = day.capitalize
        ans = animes.select_day(day).select_rcm
        return ans.print_animes(1) unless ans.empty?
        return 'ありませ〜んｗｗｗｗ'
      else
        return nil
      end
    end
  end
end

