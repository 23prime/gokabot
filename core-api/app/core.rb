Dir[File.join(File.dirname(__FILE__), '../app/**/*.rb')].sort.each { |f| require f }

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
