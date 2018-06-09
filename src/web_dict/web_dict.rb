require "mechanize"
require "uri"

module WebDict
  class WebDict
    def browse(keyword)
      agent = Mechanize.new
      query = URI::escape(keyword.strip)
      page = agent.get("#{uri}#{query}")
      return extract_abstract(page)
    rescue Mechanize::Error => e
      return nil
    end

    private

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
