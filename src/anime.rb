require 'yaml'
class Anime
  module Season
    module_function

    def get_season(month)
      return 'winter' if [1, 2, 3].include?(month)
      return 'spring' if [4, 5, 6].include?(month)
      return 'summer' if [7, 8, 9].include?(month)
      return 'fall' if [10, 11, 12].include?(month)
    end
  end

  @@d = Time.now.localtime('+05:00')
  @@year = @@d.year
  @@month = @@d.month
  @@season = Season.get_season(@@month)
  @@next_season = Season.get_season((@@month + 3) % 12)
  @@animes = YAML.safe_load(File.open('./docs/animes.yaml', 'r').read)

  def select_term(animes, year, season)
    year = year.to_s
    return animes.select { |anime|
        anime['year'] == year && anime['season'] == season
      }
  end

  def select_day(animes, day)
    return animes.select { |anime| anime['day'] == day }
  end

  def select_rcm(animes)
    return animes.select { |anime| anime['recommend'] }
  end

  def print_animes(animes, n)
    ans = ''
    animes.each do |anime|
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

  def sort_by_time(animes)
    return animes.sort_by { |a| a['time'] }
  end

  def sort_animes(animes)
    days = %w[Sun Mon Tue Wed Thu Fri Sat]
    ans = []
    days.each do |day|
      day_animes = select_day(animes, day)
      ans += sort_by_time(day_animes)
    end
    return ans
  end

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
    animes = sort_animes(select_term(@@animes, @@year, @@season))
    year2 = @@year
    year2 += 1 if @@season == 'fall'
    next_animes = sort_animes(select_term(@@animes, year2, @@next_season))

    case day
    when /^all|今期#{ANIME_OF}/i
      return print_animes(animes, 0)
    when /^今期の(オススメ|おすすめ)$/i
      ans = select_rcm(animes)
      return print_animes(ans, 0)
    when /^next|来期#{ANIME_OF}/i
      return print_animes(next_animes, 0)
    when /^来期の(オススメ|おすすめ)$/i
      ans = select_rcm(next_animes)
      return print_animes(ans, 0)
    when WEEK
      ans = select_day(animes, day)
      return print_animes(ans, 1)
    when WEEK_RCM
      day = day.capitalize
      ans0 = select_day(animes, day)
      ans = select_rcm(ans0)
      return print_animes(ans, 1) unless ans.empty?
      return 'ありませ〜んｗｗｗｗ'
    else
      return nil
    end
  end
end
