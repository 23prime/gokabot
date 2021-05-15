require 'logger'

module LogConfig
  @@logger = Logger.new($stdout)
  datetime_format = '%Y-%m-%d %H:%M:%S.%03N'
  @@logger.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime.strftime(datetime_format)}] [#{severity}] [#{progname}] #{msg}\n"
  end

  def self.get_logger
    return @@logger
  end
end
