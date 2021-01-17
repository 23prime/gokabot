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

      Gokabous.establish_connection(ENV['DATABASE_URL'])
    end

    def select_all_sentences
      query = 'select sentence from gokabot.gokabous'
      Gokabous.connection_pool.with_connection do |con|
        return con.select_values(query)
      end
    end

    def delete(sentence)
      Gokabous.where(
        sentence: sentence
      ).delete_all

      @logger.debug("Delete '#{sentence}' from DB: Count -> #{count_all}")
    end

    def insert(date, sentence)
      Gokabous.create(
        sentence: sentence,
        reg_date: date
      )

      @logger.debug("Insert '#{sentence}' to DB: Count -> #{count_all}")
    end

    def count_all
      query = 'select count (*) from gokabot.gokabous'
      res = []

      Gokabous.connection_pool.with_connection do |con|
        res = con.select_all(query).to_a
      end

      return res[0]['count']
    end
  end
end
