# coding: utf-8
require 'yaml'

$animes = File.open('./docs/18summer.yaml', 'r').read


class Anime

  ANIME_OF = /(のアニメ|)$/
  DAY_ANIME_OF = /曜(日|)#{ANIME_OF}/
  DAY = /(day|)$/i
  WEEK = /^Sun$|^Mon$|^Tue$|^Wed$|^Thu$|^Fri$|^Sat$/i

  def convert(msg)
    wdays = %w[Sun Mon Tue Wed Thu Fri Sat]
    today = Time.now.localtime("+05:00").wday

    case msg
    when /^all|今期#{ANIME_OF}/i
      'All'
    when /^sun#{DAY}|^日#{DAY_ANIME_OF}/i
      'Sun'
    when /^mon#{DAY}|^月#{DAY_ANIME_OF}/i
      'Mon'
    when /^tue(sday|)$|^火#{DAY_ANIME_OF}/i
      'Tue'
    when /^wed(nesday|)$|^水#{DAY_ANIME_OF}/i
      'Wed'
    when /^thu(rsday|)$|^木#{DAY_ANIME_OF}/i
      'Thu'
    when /^fri#{DAY}|^金#{DAY_ANIME_OF}/i
      'Fri'
    when /^sat#{DAY}|^土#{DAY_ANIME_OF}/i
      'Sat'
    when /^今日#{ANIME_OF}|^today$/i
      wdays[today]
    when /^昨日#{ANIME_OF}|^yesterday$/i
      wdays[(today + 1) % 7]
    when /^明日#{ANIME_OF}|^tomorrow$/i
      wdays[today - 1]
    else
      msg
    end
  end


  def answer(msg)
    day = convert(msg)

    case day
    when /^All$/
      return $animes
    when WEEK
      $animes = YAML.load($animes)
      return $animes[day].join("\n")
    else
      return nil
    end
  end
end