require 'dotenv/load'
require 'net/http'
require 'uri'
require 'json'

require './app/log_config'

class CityId
  attr_reader :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end
end

class Weather
  include LogConfig

  @@default_city = 'tokyo'
  @@city_ids = JSON.parse(File.open('./docs/city_id.json', 'r').read)
                   .map { |hash| CityId.new(hash['id'], hash['name']) }

  def initialize
    @logger = @@logger.clone
    @logger.progname = self.class.to_s

    @city = @@default_city.clone
    @city_id = get_city_id(@city)
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
    change_city(@@default_city)
    return ans
  end

  def self.get_default_city
    return @@default_city
  end

  private

  def get_city_id(city_name)
    result = @@city_ids.select { |city_id| city_id.name == city_name }
    return nil if result.empty?
    return result[0].id
  end

  def change_city(city_name)
    @city = city_name
    @logger.debug("Set city: '#{@city}'")

    @city_id = get_city_id(city_name)
  end

  def get_weather_info
    # Get weather infomation of the @city
    base_uri = 'https://api.openweathermap.org/data/2.5/weather?'

    uri = URI.parse("#{base_uri}&appid=#{ENV['OPEN_WEATHER_API_KEY']}&id=#{@city_id}&units=metric")
    weather_json = Net::HTTP.get(uri)

    return JSON.parse(weather_json)
  end

  def get_weather(_date)
    return '分かりませ〜んｗ' if @city_id.nil?

    weather_info = get_weather_info
    weather = weather_info['weather'][0]['main']

    main = weather_info['main']
    now_temp = main['temp']
    min_temp = main['temp_min']
    max_temp = main['temp_max']

    result = "> #{@city.capitalize}の現在の天気 <\n"
    result += "#{weather}\n"
    result += "現在の気温：#{now_temp}℃\n"
    result += "最高気温：#{max_temp}℃\n"
    result += "最低気温：#{min_temp}℃"
    return result
  end
end
