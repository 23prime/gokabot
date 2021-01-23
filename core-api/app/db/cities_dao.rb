require_relative '../log_config'
require_relative '../models/cities'

class CitiesDao
  include LogConfig

  def initialize
    @logger = @@logger.clone
    @logger.progname = self.class.to_s
  end

  def select_all_cities
    return Cities.all
  end

  def select_cities_by_name(name)
    result = Cities
             .where(name: name)
             .or(Cities.where(jp_name: name))
             .pluck(:id)
    @logger.info("Select #{result} by name [#{name}]")
    return result
  end
end
