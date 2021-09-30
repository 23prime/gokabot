class Animes < ActiveRecord::Base
  include LogConfig

  LOGGER = LogConfig.get_logger(name)

  self.table_name = 'gokabot.animes'

  def self.select_season_animes(year, season)
    result = Animes
             .select(:time, :title, :station, :day)
             .where(year: year, season: season)
    LOGGER.info("Select #{result.length} animes by year/season: [#{year}/#{season}]")
    return result
  end

  def self.select_season_recommend_animes(year, season)
    result = Animes
             .select(:time, :title, :station, :day)
             .where(year: year, season: season, recommend: true)
    LOGGER.info("Select #{result.length} animes by year/season: [#{year}/#{season}]")
    return result
  end

  def self.select_day_animes(year, season, day)
    result = Animes
             .select(:time, :title, :station)
             .where(year: year, season: season, day: day)
    LOGGER.info("Select #{result.length} animes by year/season/day: [#{year}/#{season}/#{day}]")
    return result
  end

  def self.select_day_recommend_animes(year, season, day)
    result = Animes
             .select(:time, :title, :station)
             .where(year: year, season: season, recommend: true, day: day)
    LOGGER.info("Select #{result.length} animes by year/season/day: [#{year}/#{season}/#{day}]")
    return result
  end
end
