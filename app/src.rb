require_relative './src/gokabou/answerer.rb'
require_relative './src/anime/answerer.rb'
require_relative './src/weather.rb'
require_relative './src/nyokki.rb'
require_relative './src/denippi.rb'
require_relative './src/pigeons.rb'
require_relative './src/web_dict/answerer.rb'
require_relative './src/texrenderer.rb'
require_relative './src/searchdolls.rb'
require_relative './src/collectdebts.rb'

$ANS_OBJS = [
  Nyokki.new,
  Gokabou::Answerer.new,
  Anime::Answerer.new,
  Weather.new,
  WebDict::Answerer.new,
  Denippi.new,
  Tex.new,
  Pigeons.new,
  DflSearch.new,
  CollectDebts.new
]
