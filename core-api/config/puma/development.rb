require 'active_record'
require 'puma_worker_killer'

threads 0, 2
workers 2
preload_app!

before_fork do
  PumaWorkerKiller.config do |config|
    config.ram = 2**9
    config.frequency = 5
    config.percent_usage = 0.7
    config.rolling_restart_frequency = 60
    config.reaper_status_logs = true
  end

  PumaWorkerKiller.start
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
