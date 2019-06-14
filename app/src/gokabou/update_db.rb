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
      if updatable(msg, user_id)
        date = Date.today.strftime('%Y-%m-%d')
        insert_data(date, msg)

        @all_data = @con.select_all(@query_a).to_hash
        @all_sentences = @con.select_values(@query_s)

        @update_counter += 1
      end
    end

    def updatable(msg, user_id)
      gid = ENV['GOKABOU_USER_ID']

      unless user_id == gid && msg.length > 4 && msg.length <= 300
        return false
      end

      return false if include_uri?(msg)
      return !@all_sentences.include?(msg)
    end

    def include_uri?(msg)
      splited = msg.split(/[[:space:]]/)
      splited.map! { |str| str =~ URI::DEFAULT_PARSER.regexp[:ABS_URI] }

      return splited.any?
    end

    # Will be implement...
    # def delete_data
    # end
  end
end
