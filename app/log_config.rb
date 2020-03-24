require 'logger'

module LogConfig
  @@logger = Logger.new(STDOUT)
  datetime_format = '%Y-%m-%d %H:%M:%S.%03N'
  @@logger.formatter = proc do |severity, datetime, _progname, msg|
    "[#{datetime.strftime(datetime_format)}] #{severity}\t#{msg}\n"
  end
end
