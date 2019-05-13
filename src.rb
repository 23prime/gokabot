require './src/gokabou.rb'
require './src/anime/answerer.rb'
require './src/weather.rb'
require './src/nyokki.rb'
require './src/denippi.rb'
require './src/pigeons.rb'
require './src/web_dict/answerer.rb'
require './src/texrenderer.rb'
require './src/searchdolls.rb'

$OBJS = [
  Nyokki.new,
  Gokabou.new,
  Anime::Answerer.new,
  Weather.new,
  WebDict::Answerer.new,
  Denippi.new,
  Tex.new,
  Pigeons.new,
  Dfl_search.new
]
