# coding: utf-8
require 'yaml'
require 'pp'


def convert_wday(day)
  case day
  when 'All', 'all', '今期', '今期のアニメ'
    'All'
  when 'Sun', 'Sunday', '日曜', '日曜日', '日曜日のアニメ'
    'Sun'
  when 'Mon', 'Monday', '月曜', '月曜日', '月曜日のアニメ'
    'Mon'
  when 'Tue', 'Tueday', '火曜', '火曜日', '火曜日のアニメ'
    'Tue'
  when 'Wed', 'Wedday', '水曜', '水曜日', '水曜日のアニメ'
    'Wed'
  when 'Thu', 'Thuday', '木曜', '木曜日', '木曜日のアニメ'
    'Thu'
  when 'Fri', 'Friday', '金曜', '金曜日', '金曜日のアニメ'
    'Fri'
  when 'Sat', 'Satday', '土曜', '土曜日', '土曜日のアニメ'
    'Sat'
  else
    day
  end
end


def anime_filter(str, day)
  day = convert_wday(day)
  case day
  when 'All', '今期'
    str
  when 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
    animes = YAML.load(str)
    animes[day].join("\n")
  end
end
