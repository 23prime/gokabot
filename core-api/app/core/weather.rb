require 'dotenv/load'
require 'json'
require 'faraday'

require_relative '../log_config'
require_relative '../db/cities_dao'

class CityId
  attr_reader :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end
end

class Weather
  include LogConfig

  @@default_city_name = 'tokyo'

  def initialize
    @logger = @@logger.clone
    @logger.progname = self.class.to_s

    @cities_dao = CitiesDao.new

    @city_name = @@default_city_name.clone
    @city_id = get_city_id(@city_name)
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

    change_city(msg1.strip.downcase) unless msg1.nil?

    ans = get_weather(date)
    change_city(@@default_city_name)
    return ans
  end

  def self.get_default_city
    return @@default_city_name
  end

  private

  def get_city_id(city_name)
    city_ids = @cities_dao.select_cities_by_name(city_name)
    return nil if city_ids.empty?
    return city_ids[0] # fetch first 1
  end

  def change_city(city_name)
    @city_name = city_name
    @city_id = get_city_id(city_name)
    @logger.debug("Set city: id => [#{@city_id}], name => [#{@city_name}]")
  end

  def get_weather_info
    # Get weather infomation of the @city_name
    response = Faraday.new.get do |req|
      req.url 'https://api.openweathermap.org/data/2.5/weather'
      req.params = {
        'appid' => ENV['OPEN_WEATHER_API_KEY'],
        'id' => @city_id,
        'units' => 'metric'
      }
    end

    return nil unless response.status == 200
    return JSON.parse(response.body)
  end

  def get_weather(_date)
    return '分かりませ〜んｗ' if @city_id.nil?

    weather_info = get_weather_info

    return '天気を取得できませんでした〜ｗ' if weather_info.nil?

    weather = weather_info['weather'][0]['main']

    main = weather_info['main']
    now_temp = main['temp']
    min_temp = main['temp_min']
    max_temp = main['temp_max']

    result = "> #{@city_name.capitalize}の現在の天気 <\n"
    result += "#{weather}\n"
    result += "現在の気温：#{now_temp}℃\n"
    result += "最高気温：#{max_temp}℃\n"
    result += "最低気温：#{min_temp}℃"
    return result
  end
end
