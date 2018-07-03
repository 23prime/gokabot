# coding: utf-8
require 'yaml'

module Anime
  def self.convert(day)
    case day
    when 'All', 'all', '今期', '今期のアニメ'
      'All'
    when 'Sun', 'Sunday', '日曜', '日曜日', '日曜のアニメ', '日曜日のアニメ'
      'Sun'
    when 'Mon', 'Monday', '月曜', '月曜日', '月曜のアニメ', '月曜日のアニメ'
      'Mon'
    when 'Tue', 'Tueday', '火曜', '火曜日', '火曜のアニメ', '火曜日のアニメ'
      'Tue'
    when 'Wed', 'Wedday', '水曜', '水曜日', '水曜のアニメ', '水曜日のアニメ'
      'Wed'
    when 'Thu', 'Thuday', '木曜', '木曜日', '木曜のアニメ', '木曜日のアニメ'
      'Thu'
    when 'Fri', 'Friday', '金曜', '金曜日', '金曜のアニメ', '金曜日のアニメ'
      'Fri'
    when 'Sat', 'Satday', '土曜', '土曜日', '土曜のアニメ', '土曜日のアニメ'
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
