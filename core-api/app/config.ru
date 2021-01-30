require_relative 'main'

$stdout.sync = true

run Rack::URLMap.new({ '/' => Controllers })
