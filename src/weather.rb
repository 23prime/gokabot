# coding: utf-8
require 'net/http'
require 'uri'
require 'json'


city_id = '080020' # 土浦
uri = URI.parse('http://weather.livedoor.com/forecast/webservice/json/v1?city=' + city_id)
weather_json = Net::HTTP.get(uri)
$city_all = JSON.parse(weather_json)


def mk_weather(num)
  case num
  when 0, 1
    city = 'つくば市'
    day_weather = $city_all['forecasts'][num]
    day = day_weather['dateLabel']
    telop = day_weather['telop']
    maxp = day_weather['temperature']['max']
    minp = day_weather['temperature']['min']

    if maxp == nil && minp == nil
      return '> ' + city + 'の' + day + "の天気 <\n" + telop
    else
      maxc = maxp['celsius']
      minc = minp['celsius']
      saikou = '最高気温：'
      saitei = '最低気温：'
      saikou = '予想' + saikou if num == 1
      saitei = '予想' + saitei if num == 1
      return '> ' + city + 'の' + day + "の天気 <\n" + telop + "\n" + saikou + maxc + "℃\n" + saitei + minc + '℃'
    end
  end
end
