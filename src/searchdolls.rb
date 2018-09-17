require 'cgi'
require 'open-uri'
require 'nokogiri'

class Dfl_search
  
  BASE_URI = "https://wikiwiki.jp/dolls-fl/"

  def get_doll_pict(doll_name)
    charset = nil
    url = BASE_URI << CGI.escape(doll_name)
    url.gsub!('+','%20')
    begin
      doc = Nokogiri::HTML.parse(open(url),nil,"utf-8")
      pic_dir = doc.xpath('//img [contains (@src, "plugin")] /@src')[0].inner_text
    rescue 
      return "該当するドールが見つかりません"
    end
    $reply_type = 'image'
    (BASE_URI << pic_dir).sub(/&rev=.+/,"")
  end


  def answer(msg)
    if msg =~ /^doll /
      doll_name = msg.sub(/^doll /,"")
      get_doll_pict(doll_name)
    end
  end

end


