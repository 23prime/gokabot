require 'active_record'
require 'puma_worker_killer'

threads 0, 2
workers 2
preload_app!

before_fork do
  PumaWorkerKiller.config do |config|
    config.ram = 512
    config.frequency = 60
    config.percent_usage = 0.95
    config.rolling_restart_frequency = 60 * 60 * 24
    config.reaper_status_logs = true
  end

  PumaWorkerKiller.start
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
