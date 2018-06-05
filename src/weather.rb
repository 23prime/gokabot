# coding: utf-8
require 'net/http'
require 'uri'
require 'json'


city_id = '080020' # 土浦
uri = URI.parse('http://weather.livedoor.com/forecast/webservice/json/v1?city=' + city_id)
weather_json = Net::HTTP.get(uri)
$city_all = JSON.parse(weather_json)


def mk_weather(num)
  city = 'つくば市'
  day_weather = $city_all['forecasts'][num]
  day = day_weather['dateLabel']
  telop = day_weather['telop']

  case num
  when 0
    maxc = day_weather['temperature']['max']['celsius']
    minc = day_weather['temperature']['min']['celsius']
    if maxc == nil && minc == nil
      return '> ' + city + 'の' + day + "の天気 <\n" + telop
    else
      return '> ' + city + 'の' + day + "の天気 <\n" + telop + "\n最高気温：" + maxc + "℃\n最低気温：" + minc + '℃'
    end
  when 1
    return '> ' + city + 'の' + day + "の天気 <\n" + telop
  end
end
