require_relative 'regexps'

module Anime
  class WeekDay
    def convert(msg)
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
      else
        return nil
      end
    end
  end

  class Day
    def initialize(wdays, today)
      @wdays = wdays
      @today = today
    end
    
    def convert(msg)
      case msg
      when /^一昨日#{ANIME_OF}|^day before yesterday$/i
        return @wdays[@today - 2]
      when /^昨日#{ANIME_OF}|^yesterday$/i
        return @wdays[@today - 1]
      when /^今日#{ANIME_OF}|^today$/i
        return @wdays[@today]
      when /^明日#{ANIME_OF}|^tomorrow$/i
        return @wdays[(@today + 1) % 7]
      when /^明後日#{ANIME_OF}|^day after tomorrow$/i
        return @wdays[(@today + 2) % 7]
      else
        return nil
      end
    end
  end

  class Recommend
    def initialize(wdays, today)
      @wdays = wdays
      @today = today
    end

    def convert(msg)
      case msg
      when /^一昨日の#{RECOMMEND}/i
        return @wdays[@today - 2].downcase
      when /^昨日の#{RECOMMEND}/i
        return @wdays[@today - 1].downcase
      when /^(今日の|)#{RECOMMEND}/i
        return @wdays[@today].downcase
      when /^明日の#{RECOMMEND}/i
        return @wdays[(@today + 1) % 7].downcase
      when /^明後日の#{RECOMMEND}/i
        return @wdays[(@today + 2) % 7].downcase
      else
        return nil
      end
    end
  end
end
