srcs = [
  '../app/src/*/answerer.rb',
  '../app/src/*.rb'
]

srcs.each do |src|
  Dir[File.join(File.dirname(__FILE__), src)].each { |f| require f }
end

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
  BaseballNews::Answerer.new
]
