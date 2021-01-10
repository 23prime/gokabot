require 'sinatra'
require 'dotenv/load'
require 'rest-client'

require_relative './src/push/push'
require_relative './src/push/ramdom_push'
require_relative './src/push/push_discord'
require_relative './response'

get '/' do
  'Hello, gokabot!'
end

post '/callback/line' do
  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  Response::Response.response(body, signature)
  return 200
end

post '/callback' do
  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  Response::Response.response(body, signature)
  return 200
end

post '/push' do
  msg = params[:msg]
  target = params[:target]
  return 401 if msg.nil? || target.nil?
  return Push.new.send_push_msg(msg, target)
end

post '/push/random' do
  target = params[:target]
  return 401 if target.nil?
  return RamdomPush.new.send_push_msg(target)
end

post '/push/discord' do
  msg = params[:msg]
  return 401 if msg.nil?
  return 200 if PushDiscord.new.send_message(msg)
  return 500
end
