require 'cgi'
require 'open-uri'
require 'nokogiri'

class Dfl_search
  
  BASE_URI = "https://wikiwiki.jp/dolls-fl/"

  def get_doll_pict(doll_name,pict_type)
    charset = nil
    damage = ""
    doll_name =  CGI.escape(doll_name)
    doll_name.gsub!('+','%20')
    damage = "_damage" if pict_type==1
    url=BASE_URI+doll_name
    begin
      doc = Nokogiri::HTML.parse(open(url),nil,"utf-8")
      pic_dir = doc.xpath('//img [contains(@src, "plugin") and contains(@src, "'+damage+'")] /@src')[0].inner_text
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
        pict_type=1
        doll_name.sub!(/damage /,"")
      end
      get_doll_pict(doll_name,pict_type)
    end
  end

end


