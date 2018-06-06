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
  # 0 -> today, 1 -> tomorrow.
  # So, forecasts[0] -> today weather, forecasts[0] -> tomorrow weather.
  when 0, 1
    city        = 'つくば市'
    day_weather = $city_all['forecasts'][num]

    day   = day_weather['dateLabel']  # 今日 or 明日
    date  = day_weather['date'][8, 9] # yyyy-mm-dd -> dd
    telop = day_weather['telop']      # example: 晴, 曇時々雨

    min_temp    = day_weather['temperature']['min']
    max_temp    = day_weather['temperature']['max']
    min_celsius = ''
    max_celsius = ''

    unless min_temp == nil
      min_celsius = '最低気温：' + min_temp['celsius'] + "℃"
      min_celsius = '予想' + min_celsius if num == 1
    end

    unless max_temp == nil
      max_celsius = '最高気温：' + max_temp['celsius'] + "℃\n" if max_temp != nil
      max_celsius = '予想' + max_celsius if num == 1
    end

    return '> ' + city + 'の' + day + '（' + date + "日）の天気 <\n" + telop + "\n" + max_celsius + min_celsius
  end
end
