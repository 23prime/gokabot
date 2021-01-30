require 'dotenv/load'
require 'json'
require 'sinatra'
require 'sinatra/cors'

require_relative 'core'
require_relative 'callback'
require_relative 'discord/push'
require_relative 'line/callback'
require_relative 'line/push'
require_relative 'line/ramdom_push'
require_relative 'log_config'

class ControllerConfig
  include LogConfig
  attr_reader :logger

  def initialize
    @logger = @@logger.clone
    @logger.progname = self.class.to_s
  end
end

config = ControllerConfig.new

set :allow_origin, '*'
set :allow_methods, 'GET,POST'
set :allow_headers, 'Content-Type, Accept'

get '/' do
  'Hello, gokabot!'
end

post '/callback' do
  body = request.body.read
  return Callback.response(body).to_json
end

post '/line/callback' do
  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  Line::Callback.response(body, signature)
  return 200
end

post '/line/push' do
  begin
    body = JSON.parse(request.body.read)
    msg = body['message']
    target_id = body['target_id']
  rescue => e
    config.logger.error("Invalid request body\n#{e}")
    return 400
  end

  if msg.nil? || target_id.nil?
    config.logger.error("The request does not include 'message' or 'target_id'")
    return 400
  end

  return Line::Push.new.send_msg(msg, target_id)
end

post '/line/push/random' do
  begin
    body = JSON.parse(request.body.read)
    target_id = body['target_id']
  rescue => e
    config.logger.error("Invalid request body\n#{e}")
    return 400
  end

  if target_id.nil?
    config.logger.error("The request does not include 'target_id'")
    return 400
  end

  return Line::RamdomPush.new.send_msg(target_id)
end

post '/discord/push' do
  msg = params[:msg]
  return 401 if msg.nil?
  return 200 if Discord::Push.new.send_message(msg)
  return 500
end

post '/discord/push/random' do
  return 200 if Discord::RamdomPush.new.send_message
  return 500
end
