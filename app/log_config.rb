require 'logger'

module LogConfig
  @@logger = Logger.new(STDOUT)
  datetime_format = '%Y-%m-%d %H:%M:%S.%03N'
  @@logger.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime.strftime(datetime_format)}] [#{progname}] [#{severity}] #{msg}\n"
  end
end
