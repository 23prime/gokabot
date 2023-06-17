require 'dotenv/load'
require 'json'
require 'sinatra'
require 'sinatra/cors'

require_relative 'core'
require_relative 'callback'
require_relative 'db_config'
require_relative 'discord/push'
require_relative 'line/callback'
require_relative 'line/push'
require_relative 'line/ramdom_push'
require_relative 'log_config'

# Override Rack default logger
module Rack
  class CommonLogger
    include LogConfig

    LOGGER = LogConfig.get_logger(name)

    def call(env)
      began_at = Time.now.to_f
      status, headers, body = @app.call(env)
      log(env, status, headers, body, began_at) if @app.is_a?(Rack::Logger)
      return [status, headers, body]
    end

    def log(env, status, headers, body, began_at)
      addr = env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR'] || '-'
      user = env['REMOTE_USER'] || '-'
      method = env['REQUEST_METHOD']
      script = env['SCRIPT_NAME']
      path = env['PATH_INFO'] + (env['QUERY_STRING'].empty? ? '' : "?#{env['QUERY_STRING']}")
      protocol = env['SERVER_PROTOCOL']
      status = status.to_s[0..3]
      length = extract_content_length(headers)
      duration = (Time.now.to_f - began_at).round(3)

      msg = "#{addr} - #{user} \"#{method} #{script}#{path} #{protocol}\" #{status} #{length} #{duration}"

      LOGGER.info(msg)
      LOGGER.debug("Response Body => #{body}")
    end
  end
end

class Controllers < Sinatra::Application
  include LogConfig

  LOGGER = LogConfig.get_logger(name)

  set :server, :puma

  register Sinatra::Cors

  set :allow_origin, '*'
  set :allow_methods, 'GET,POST'
  set :allow_headers, 'Content-Type, Accept'

  get '/' do
    "Hello, gokabot!\n"
  end

  post '/callback' do
    body = request.body.read
    result = Callback.response(body)

    if result.nil?
      status 400
      return
    end

    return result.to_json
  end

  post '/line/callback' do
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    status Line::Callback.response(body, signature)
    return
  end

  post '/line/push' do
    begin
      body = JSON.parse(request.body.read)
      msg = body['message']
      target_id_alias = body['target_id']
    rescue => e
      LOGGER.error("Invalid request body\n#{e}")
      status 400
      return
    end

    target_id = ENV.fetch(target_id_alias, nil)

    if msg.nil? || target_id.nil?
      LOGGER.error("Invalid message or target => message: #{msg}, target_id_alias => #{target_id_alias}")
      status 400
      return
    end

    status Line::Push.new.send_msg(msg, target_id)
  end

  post '/line/push/random' do
    begin
      body = JSON.parse(request.body.read)
      target_id_alias = body['target_id']
    rescue => e
      LOGGER.error("Invalid request body\n#{e}")
      status 400
      return
    end

    target_id = ENV.fetch(target_id_alias, nil)

    if target_id.nil?
      LOGGER.error("Invalid target => message: #{msg}, target => #{target_id_alias}")
      status 400
      return
    end

    status Line::RamdomPush.new.send_msg(target_id)
  end

  post '/discord/push' do
    begin
      body = JSON.parse(request.body.read)
      msg = body['message']
      target_id = body['target_id']
    rescue => e
      LOGGER.error("Invalid request body\n#{e}")
      status 400
      return
    end

    if msg.nil?
      LOGGER.error("The request does not include 'message'")
      status 400
      return
    end

    status Discord::Push.new.send_message(msg, target_id)
  end

  post '/discord/push/random' do
    begin
      body = JSON.parse(request.body.read)
      target_id = body['target_id']
    rescue => e
      LOGGER.error("Invalid request body\n#{e}")
      status 400
      return
    end

    status Discord::RamdomPush.new.send_message(target_id)
  end

  error 404 do
    'Not Found'
  end
end
