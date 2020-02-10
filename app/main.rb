require 'sinatra'
require 'dotenv/load'
require 'rest-client'
require_relative './response.rb'

get '/' do
  'Hello, gokabot!'
end

post '/callback' do
  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  Response::Response.response(body, signature)
  'OK'
end
