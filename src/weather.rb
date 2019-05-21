require 'net/http'
require 'uri'
require 'json'

class Weather
  def initialize
    # Default city
    @city = '東京'

    # Get city ID
    @city_ids = JSON.parse(File.open('./docs/city_id.json', 'r').read)
    @city_id = @city_ids[@city]
  end

  def change_city(city)
    @city_id = @city_ids[city]
  end

  def get_weather_info
    # Get weather infomation of the @city
    base_uri = 'http://weather.livedoor.com/forecast/webservice/json/v1?city='
    uri = URI.parse("#{base_uri}#{@city_id}")
    weather_json = Net::HTTP.get(uri)
    info = JSON.parse(weather_json)
    return info
  end

  def get_mosts(temp, date, is_max)
    return '' if temp.nil?

    most = '最低'
    most = '最高' if is_max

    celsius = "#{most}気温：#{temp['celsius']}℃"
    celsius = "予想#{celsius}" if date == 1
    celsius = "\n#{celsius}"
    return celsius
  end

  def get_weather(date)
    return '分かりませ〜んｗ' if @city_id.nil?

    weather_info = get_weather_info
    day_weather = weather_info['forecasts'][date]

    day = day_weather['dateLabel']   # 今日 or 明日
    date = day_weather['date'][8, 9] # yyyy-mm-dd -> dd
    telop = day_weather['telop']     # example: 晴, 曇時々雨

    min_temp = day_weather['temperature']['min']
    max_temp = day_weather['temperature']['max']

    min_celsius = get_mosts(min_temp, date, false)
    max_celsius = get_mosts(max_temp, date, true)

    return "> #{@city}の#{day}（#{date}日）の天気 <\n#{telop}#{max_celsius}#{min_celsius}"
  end

  def answer(msg)
    msg_split = msg.split(/[[:blank:]]+/)
    msg0 = msg_split[0].strip
    msg1 = msg_split[1]

    case msg0
    when /^(今日の|)天気$/
      date = 0
    when /^明日の天気$/
      date = 1
    else
      return nil
    end

    unless msg1.nil?
      msg1.strip!
      change_city(msg1)
    end

    return get_weather(date)
  end
end
