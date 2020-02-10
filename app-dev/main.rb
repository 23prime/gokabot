require 'sinatra'
require 'dotenv/load'
require 'json'
require 'rest-client'
require_relative './response.rb'

before do
  content_type :json
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => %w[POST OPTIONS],
          'Access-Control-Allow-Headers' => 'Content-Type, Accept'
end

get '/' do
  'Hello, gokabot!'
end

options '/callback' do
  200
end

post '/callback' do
  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  reply = Response::Response.response(body, signature)
  reply.to_json
end
