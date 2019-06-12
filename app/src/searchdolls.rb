require 'cgi'
require 'open-uri'
require 'nokogiri'

class DflSearch
  BASE_URI = 'https://wikiwiki.jp/dolls-fl/'

  def get_doll_pict(doll_name, pict_type)
    damage = ''
    doll_name = CGI.escape(doll_name)
    doll_name.gsub!('+', '%20')
    damage = '_damage' if pict_type == 1
    url = BASE_URI + doll_name
    begin
      doc = Nokogiri::HTML.parse(URI.parse(url).open, nil, 'utf-8')
      pre_path = '//img [contains(@src, "plugin") and contains(@src, "' + damage + '")] /@src'
      pic_dir = doc.xpath(pre_path)[0].inner_text
    rescue
      return '該当するドールが見つかりません'
    end
    $reply_type = 'image'
    (BASE_URI + pic_dir).sub(/&rev=.+/, '')
  end

  def answer(*msg_data)
    msg = msg_data[0]

    return unless msg =~ /^doll /
    pict_type = 0
    doll_name = msg.sub(/^doll /, '')
    if doll_name =~ /damage/
      pict_type = 1
      doll_name.sub!(/damage /, '')
    end
    get_doll_pict(doll_name, pict_type)
  end
end
