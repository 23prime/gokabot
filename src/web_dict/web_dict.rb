require "mechanize"
require "uri"
require "timeout"
require "logger"

module WebDict
  class WebDict
    def browse(keyword)
      query = URI::escape(keyword.strip)
      page = @mechanize.get("#{uri}#{query}")
      return extract_abstract(page)
    rescue Timeout::Error => e
      log_error(e)
      return nil
    rescue Mechanize::ResponseCodeError => e
      log_error(e) unless e.response_code == "404"
      return nil
    rescue Mechanize::Error => e
      log_error(e)
      return nil
    end

    def initialize
      @mechanize = Mechanize.new()
      @mechanize.open_timeout = 2
      @mechanize.read_timeout = 2
      @mechanize.idle_timeout = 2
      @logger = Logger.new(STDERR)
    end

    private

    def log_error(error, message = nil)
      if message.nil?
        @logger.error("#{error.to_s} in #{self.class}")
      else
        @logger.error("#{error.to_s}: #{message} in #{self.class}")
      end
      @logger.error(error)
    end

    def extract_abstract(page)
      elem = page.search(first_elem_selector).first
      return nil if elem.nil?
      result = ""
      count = 0
      while result.length < min_num_characters &&
          !elem.nil? && read_further?(elem, count)
        unless skip_elem?(elem, count)
          elem = change_elem(elem, count)
          result << elem.text
        end
        count += 1
        elem = elem.next
      end
      return result
    end

    def uri
      raise NotImplementedError
    end

    def min_num_characters
      return 20
    end

    def first_elem_selector
      return 'p'
    end

    def skip_elem?(elem, count)
      return false
    end

    def read_further?(elem, count)
      return true
    end

    def change_elem(elem, count)
      elem.content = elem.content.strip
      return elem
    end
  end
end
