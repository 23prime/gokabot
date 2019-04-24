module Anime
  class Animes < Array
    attr_reader :animes

    def initialize(array)
      @animes = array.dup
    end

    def +(other)
      @anime += other.animes
    end

    def empty?
      return @animes.empty?
    end

    def select_term(year, season)
      year = year.to_s
      @animes.select! { |anime|
        anime['year'] == year && anime['season'] == season
      }
    end

    def select_day(day)
      @animes.select! { |anime| anime['day'] == day }
    end

    def select_rcm
      @animes.select! { |anime| anime['recommend'] }
    end

    def sort_animes
      days = %w[Sun Mon Tue Wed Thu Fri Sat]
      ans = []
      days.each do |day|
        day_animes = @animes.select { |anime| anime['day'] == day }
        day_animes.sort_by! { |anime| anime['time'] }
        ans += day_animes
      end
      @animes = ans
    end

    def print_animes(n)
      ans = ''
      @animes.each do |anime|
        time = anime['time']
        station = anime['station']
        title = anime['title']
        day = anime['day']
        ans << "#{day}, " if n.zero?
        ans << "#{time}, #{station}, #{title}\n"
      end
      ans.strip!
      return ans
    end
  end
end
