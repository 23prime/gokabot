require "mechanize"
require "uri"

module Wikipedia
  class << self
    def browse(keyword)
      agent = Mechanize.new
      query = URI::escape(keyword.strip)
      page = agent.get("https://ja.wikipedia.org/wiki/#{query}")
      return extract_abstract(page)
    rescue Mechanize::Error => e
      return nil
    end

    private

    def extract_abstract(page)
      e = page.search('div.mw-parser-output > p').first
      return nil if e.nil?
      remove_cites(e)
      abst = e.text
      e = e.next
      while !e.nil? && ["p", "ul", "text"].include?(e.name)
        remove_cites(e)
        abst << e.text
        e = e.next
      end
      return abst
    end

    def remove_cites(elem)
      elem.css('sup.reference').each do |e|
        e.remove
      end
    end
  end
end
