require_relative 'main'
require_relative 'db_config'

$stdout.sync = true

run Sinatra::Application
