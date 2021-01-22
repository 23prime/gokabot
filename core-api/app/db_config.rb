require 'active_record'
require 'dotenv/load'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
