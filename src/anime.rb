# coding: utf-8
require 'yaml'

module Anime
  def self.convert(day)
    case day
    when /^all|今期(のアニメ|)$/i
      'All'
    when /^sun(day|)$|^日曜(日|)(のアニメ|)$/i
      'Sun'
    when /^mon(day|)$|^月曜(日|)(のアニメ|)$/i
      'Mon'
    when /^tue(sday|)$|^火曜(日|)(のアニメ|)$/i
      'Tue'
    when /^wed(nesday|)$|^水曜(日|)(のアニメ|)$/i
      'Wed'
    when /^thu(rsday|)$|^木曜(日|)(のアニメ|)$/i
      'Thu'
    when /^fri(day|)$|^金曜(日|)(のアニメ|)$/i
      'Fri'
    when /^sat(day|)$|^土曜(日|)(のアニメ|)$/i
      'Sat'
    else
      day
    end
  end

  def self.filter(animes, day)
    case day
    when 'All'
      animes
    when 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
      animes = YAML.load(animes)
      animes[day].join("\n")
    end
  end
end
