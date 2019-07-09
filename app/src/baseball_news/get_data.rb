require 'open-uri'
require 'nokogiri'
require 'rexml/document'

module BaseballNews
  class GetData
    BASE_URI = 'https://baseball.yahoo.co.jp/npb/schedule/?date='

    class << self
      def scrape_page(date)
        xml = get_xml BASE_URI + date.to_s
        xpaths = ["//td[contains(@class,'yjMSt bt bb')]",
                  '//table[@class="teams"]//span/a',
                  '//table[@class="score"]//td[@class="score_r"]']
        return xpaths.map { |xp| map_text xml, xp }
      end

      def map_text(xml, xpath)
        return xml.xpath(xpath).map(&:text)
      end

      def get_xml(uri)
        return Nokogiri::HTML.parse URI.parse(uri).open, nil, 'utf-8'
      end
    end
  end
end
