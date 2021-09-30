require 'active_record'

class Gokabous < ActiveRecord::Base
  include LogConfig

  LOGGER = LogConfig.get_logger(name)

  self.table_name = 'gokabot.gokabous'

  def self.delete(sentence)
    Gokabous.where(sentence: sentence).delete_all
    LOGGER.debug("Delete '#{sentence}' from DB: Count -> #{Gokabous.all.count}")
  end

  def self.insert(date, sentence)
    Gokabous.create(sentence: sentence, reg_date: date)
    LOGGER.debug("Insert '#{sentence}' to DB: Count -> #{Gokabous.all.count}")
  end
end
