require 'net/http'
require 'uri'
require 'json'

require './app/log_config'

class Weather
  include LogConfig

  @@default_city = '東京'
  @@city_ids = JSON.parse(File.open('./docs/city_id.json', 'r').read)

  def initialize
    @@logger.progname = self.class.to_s

    @city = @@default_city.clone
    @@logger.debug("Set city: '#{@city}'")

    @city_id = @@city_ids[@city]
  end

  def answer(*msg_data)
    msg = msg_data[0]
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

    ans = get_weather(date)
    change_city(@@default_city)
    return ans
  end

  def self.get_default_city
    return @@default_city
  end

  private

  def change_city(city)
    @city = city
    @@logger.debug("Set city: '#{@city}'")

    @city_id = @@city_ids[city]
  end

  def get_weather_info
    # Get weather infomation of the @city
    base_uri = 'http://weather.livedoor.com/forecast/webservice/json/v1?city='
    uri = URI.parse("#{base_uri}#{@city_id}")
    weather_json = Net::HTTP.get(uri)
    return JSON.parse(weather_json)
  end

  def get_mosts(temp, date, is_max)
    return '' if temp.nil?

    most = '最低'
    most = '最高' if is_max

    celsius = "#{most}気温：#{temp['celsius']}℃"
    celsius = "予想#{celsius}" if date == 1
    return "\n#{celsius}"
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
end
