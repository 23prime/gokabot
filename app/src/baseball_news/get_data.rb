require 'open-uri'
require 'nokogiri'

module BaseballNews
  class GetData
    BASE_URI = 'https://baseball.yahoo.co.jp/npb/schedule/?date='

    class << self
      def scrape_page(date)
        @xml = get_xml BASE_URI + date
        return sp_page if special?
        xpaths = ["//td[contains(@class,'yjMSt bt bb')]",
                  '//table[@class="teams"]//span/a',
                  '//table[@class="score"]//td[@class="score_r"]']
        return xpaths.map { |xp| map_text @xml, xp }
      end

      def special?
        xpath = '//div [@id="gm_sch"]//table[@class="NpbSP"]'
        return !(@xml.xpath(xpath).empty?)
      end

      def sp_page
        xpaths = ['//div[contains(@class,"yjMS SPpd")]',
                  '//td[@class = "yjMS"]//i',
                  '//td[contains(@class,"score")]']
        return xpaths.map { |xp| map_text @xml, xp }
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
