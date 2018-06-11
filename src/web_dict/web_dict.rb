require "mechanize"
require "uri"
require "timeout"
require "logger"

module WebDict
  POSSIBLE_RESPONSES = ["400", "404", "410", "413", "414"]

  class WebDict
    def browse(keyword)
      query = URI::escape(keyword.strip)
      page = @mechanize.get("#{uri}#{query}")
      return extract_abstract(page)
    rescue Timeout::Error => e
      log_warn(e)
      return nil
    rescue Mechanize::ResponseCodeError => e
      log_warn(e) unless POSSIBLE_RESPONSES.include?(e.response_code)
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

    def log_warn(error, message = nil)
      if message.nil?
        @logger.warn("#{error.to_s} in #{self.class}")
      else
        @logger.warn("#{error.to_s}: #{message} in #{self.class}")
      end
    end

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
      index = 0
      while result.length < min_num_characters &&
          !elem.nil? && read_further?(elem, index)
        unless skip_elem?(elem, index)
          elem = change_elem(elem, index)
          result << elem.text
        end
        index += 1
        elem = elem.next
      end
      return result
    end

    SKIPPED_TAGS = [
      "h1", "h2", "h3", "h4", "h5", 
      "hr",
    ]

    EXPECTED_TAGS = [
      "p", "ul", "dl", "ol", "text",
    ] + SKIPPED_TAGS

    def uri
      raise NotImplementedError
    end

    def min_num_characters
      return 50
    end

    def first_elem_selector
      return 'p'
    end

    def skip_elem?(elem, index)
      return SKIPPED_TAGS.include?(elem.name)
    end

    def read_further?(elem, index)
      return EXPECTED_TAGS.include?(elem.name)
    end

    def change_elem(elem, index)
      elem.content = elem.content.strip
      return elem
    end
  end
end
