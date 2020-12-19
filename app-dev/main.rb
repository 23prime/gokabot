require 'sinatra'
require 'dotenv/load'
require 'json'
require 'rest-client'

require './app/src/push/push'
require './app/src/push/ramdom_push'
require './app/src/push/push_discord'
require_relative './response'

before do
  content_type :json
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => %w[POST OPTIONS],
          'Access-Control-Allow-Headers' => 'Content-Type, Accept'
end

get '/' do
  return 'Hello, gokabot!'
end

options '/callback' do
  return 200
end

post '/callback' do
  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  reply = Response::Response.response(body, signature)
  return reply.to_json
end

options '/push' do
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
