require 'active_record'
require 'dotenv/load'
require 'date'
require 'uri'

module Gokabou
  class Gokabous < ActiveRecord::Base
  end

  class UpdateDB
    attr_accessor :all_sentences, :update_counter

    def initialize
      Gokabous.establish_connection(
        ENV['DATABASE_URL']
      )
      @con = Gokabous.connection

      @query_a = 'select * from gokabous'
      @all_data = @con.select_all(@query_a).to_a

      @query_s = 'select sentence from gokabous'
      @all_sentences = @con.select_values(@query_s)

      @update_counter = 0
    end

    def insert_data(date, sentence)
      Gokabous.create(
        sentence: sentence,
        reg_date: date
      )

      puts "##### Insert '#{sentence}' to DB #####"
      puts "#####   Row length -> #{row_length} #####"
    end

    def delete_data(sentence)
      Gokabous.where(
        sentence: sentence
      ).delete_all

      puts "##### Delete '#{sentence}' fron DB #####."
      puts "#####   Row length -> #{row_length} #####"
    end

    def update_db(msg)
      date = Date.today.strftime('%Y-%m-%d')
      insert_data(date, msg)

      @all_data = @con.select_all(@query_a).to_a
      @all_sentences = @con.select_values(@query_s)

      @update_counter += 1
    end

    def row_length
      query = 'select count (*) from gokabous'
      res = @con.select_all(query).to_a

      return res[0]['count']
    end

    # Will be implement...
    # def delete_data(msg)
    #   @con.select_all(query)
    # end
  end
end
