require 'dotenv/load'

require_relative '../log_config'
require_relative '../models/animes'

module Anime
  class AnimesDao
    include LogConfig

    def initialize
      @logger = @@logger.clone
      @logger.progname = self.class.to_s
    end

    def select_season_animes(year, season)
      result = Animes
               .select(:time, :title, :station, :day)
               .where(year: year, season: season)
      @logger.info("Select #{result.length} animes by year/season: [#{year}/#{season}]")
      return result
    end

    def select_season_recommend_animes(year, season)
      result = Animes
               .select(:time, :title, :station, :day)
               .where(year: year, season: season, recommend: true)
      @logger.info("Select #{result.length} animes by year/season: [#{year}/#{season}]")
      return result
    end

    def select_day_animes(year, season, day)
      result = Animes
               .select(:time, :title, :station)
               .where(year: year, season: season, day: day)
      @logger.info("Select #{result.length} animes by year/season/day: [#{year}/#{season}/#{day}]")
      return result
    end

    def select_day_recommend_animes(year, season, day)
      result = Animes
               .select(:time, :title, :station)
               .where(year: year, season: season, recommend: true, day: day)
      @logger.info("Select #{result.length} animes by year/season/day: [#{year}/#{season}/#{day}]")
      return result
    end
  end
end
