require 'active_record'
require 'dotenv/load'
require 'date'

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
      @all_data = @con.select_all(@query_a).to_hash

      @query_s = 'select sentence from gokabous'
      @all_sentences = @con.select_values(@query_s)

      @update_counter = 0
    end

    def insert_data(date, sentence)
      Gokabous.create(
        sentence: sentence,
        reg_date: date
      )
    end

    def update_db(msg, user_id)
      gid = ENV['GOKABOU_USER_ID']

      if msg.length > 4 && !@all_sentences.include?(msg) && user_id == gid
        date = Date.today.strftime('%Y-%m-%d')
        insert_data(date, msg)

        @all_data = @con.select_all(@query_a).to_hash
        @all_sentences = @con.select_values(@query_s)

        @update_counter += 1
      end
    end

    # Will be implement...
    # def delete_data
    # end
  end
end
