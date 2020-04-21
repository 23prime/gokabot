require 'sinatra'
require 'dotenv/load'
require 'json'
require 'rest-client'

require './app/src/push'
require_relative './response.rb'

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
  return Push.send_push_msg(msg, target)
end
