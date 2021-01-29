require 'dotenv/load'
require 'sinatra'
require 'sinatra/cors'

require_relative 'core'
require_relative 'callback'
require_relative 'line/callback'
require_relative 'line/push'
require_relative 'line/ramdom_push'
require_relative 'discord/push'

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
  msg = params[:msg]
  target = params[:target]
  return 401 if msg.nil? || target.nil?
  return Line::Push.new.send_push_msg(msg, target)
end

post '/line/push/random' do
  target = params[:target]
  return 401 if target.nil?
  return Line::RamdomPush.new.send_push_msg(target)
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
