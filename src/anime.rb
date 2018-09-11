# coding: utf-8
require 'yaml'

module Anime

  ANIME_OF = /(のアニメ|)$/
  DAY_ANIME_OF = /曜(日|)#{ANIME_OF}/
  DAY = /(day|)$/i
  WEEK = /^Sun$|^Mon$|^Tue$|^Wed$|^Thu$|^Fri$|^Sat$/i

  def self.convert(day)
    case day
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
    else
      day
    end
  end

  def self.filter(animes, day)
    case day
    when 'All'
      animes
    when WEEK
      animes = YAML.load(animes)
      animes[day].join("\n")
    end
  end
end
