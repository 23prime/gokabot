require 'cgi'
require 'open-uri'
require 'nokogiri'

class Dfl_search
  
  BASE_URI = "https://wikiwiki.jp/dolls-fl/"

  def get_doll_pict(doll_name,pict_type)
    charset = nil
    url = BASE_URI + CGI.escape(doll_name)
    url.gsub!('+','%20')
    begin
      doc = Nokogiri::HTML.parse(open(url),nil,"utf-8")
      pic_dir = doc.xpath('//img [contains (@src, "plugin") and not(contains(@src, "gif"))] /@src')[pict_type].inner_text
    rescue
      return "該当するドールが見つかりません"
    end
    $reply_type = 'image'
    (BASE_URI + pic_dir).sub(/&rev=.+/,"")
  end


  def answer(msg)
    if msg =~ /^doll /
      pict_type=0
      doll_name = msg.sub(/^doll /,"")
      if doll_name =~ /damage/
        pict_type=3
        doll_name.sub!(/damage /,"")
      end
      get_doll_pict(doll_name,pict_type)
    end
  end

end


