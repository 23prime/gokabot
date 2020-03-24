require 'active_record'
require 'date'
require 'dotenv/load'
require 'uri'

require './app/log_config'

module Gokabou
  class Gokabous < ActiveRecord::Base
    self.table_name = 'gokabot.gokabous'
  end

  class UpdateDB
    include LogConfig

    attr_accessor :all_sentences, :update_counter

    QUERY_A = 'select * from gokabot.gokabous'
    QUERY_S = 'select sentence from gokabot.gokabous'

    def initialize
      Gokabous.establish_connection(ENV['DATABASE_URL'])

      @update_counter = 0

      Gokabous.connection_pool.with_connection do |con|
        @all_data = con.select_all(QUERY_A).to_a
        @all_sentences = con.select_values(QUERY_S)
      end
    end

    def insert_data(date, sentence)
      Gokabous.create(
        sentence: sentence,
        reg_date: date
      )

      @@logger.debug("##### Insert '#{sentence}' to DB #####")
      @@logger.debug("#####   Row length -> #{row_length} #####")
    end

    def delete_data(sentence)
      Gokabous.where(
        sentence: sentence
      ).delete_all

      @@logger.debug("##### Delete '#{sentence}' fron DB #####.")
      @@logger.debug("#####   Row length -> #{row_length} #####")
    end

    def update_db(msg)
      date = Date.today.strftime('%Y-%m-%d')
      insert_data(date, msg)

      Gokabous.connection_pool.with_connection do |con|
        @all_data = con.select_all(QUERY_A).to_a
        @all_sentences = con.select_values(QUERY_S)
      end

      @update_counter += 1
    end

    def row_length
      query = 'select count (*) from gokabot.gokabous'
      res = []

      Gokabous.connection_pool.with_connection do |con|
        res = con.select_all(query).to_a
      end

      return res[0]['count']
    end
  end
end
