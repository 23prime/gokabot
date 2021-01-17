require 'active_record'
require 'date'
require 'dotenv/load'
require 'uri'

require_relative '../log_config'
require_relative '../models/gokabous'

module Gokabou
  class GokabousDao
    include LogConfig

    def initialize
      @logger = @@logger.clone
      @logger.progname = self.class.to_s
    end

    def select_all_sentences
      return Gokabous.pluck(:sentence)
    end

    def delete(sentence)
      Gokabous.where(sentence: sentence).delete_all
      @logger.debug("Delete '#{sentence}' from DB: Count -> #{count_all}")
    end

    def insert(date, sentence)
      Gokabous.create(sentence: sentence, reg_date: date)
      @logger.debug("Insert '#{sentence}' to DB: Count -> #{count_all}")
    end

    def count_all
      return Gokabous.all.count
    end
  end
end
