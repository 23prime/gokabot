require 'active_record'

class Cities < ActiveRecord::Base
  include LogConfig

  LOGGER = LogConfig.get_logger(name)

  self.table_name = 'gokabot.cities'

  def self.select_cities_by_name(name)
    result = Cities
             .where(name: name)
             .or(Cities.where(jp_name: name))
             .pluck(:id)
    LOGGER.info("Select #{result} by name [#{name}]")
    return result
  end
end
