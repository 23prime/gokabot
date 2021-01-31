require_relative 'controllers'

$stdout.sync = true

run Rack::URLMap.new({ '/' => Controllers })
