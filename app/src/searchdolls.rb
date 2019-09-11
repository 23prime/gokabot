require 'cgi'
require 'open-uri'

class DflSearch
  @@base_uri = 'https://cdn.wikiwiki.jp/to/w/dolls-fl/'

  def mk_url(doll_name)
    is_damage = damaged?(doll_name)

    doll_name.sub!(/damage /, '') if is_damage
    doll_name = CGI.escape(doll_name)
    doll_name.gsub!('+', '%20')

    file_name = doll_name
    file_name += '_damage' if is_damage

    url = "#{doll_name}/::ref/#{file_name}.jpg"
    return @@base_uri + url
  end

  def fetchable(url)
    begin
      open(url)
    rescue OpenURI::HTTPError
      return false
    end

    return true
  end

  def damaged?(doll_name)
    return true if doll_name =~ /damage/
    return false
  end

  def get_doll_pict(doll_name)
    url = mk_url(doll_name)
    return '該当するドールが見つかりません' unless fetchable(url)

    $reply_type = 'image'
    return url
  end

  def answer(*msg_data)
    msg = msg_data[0]
    return unless msg =~ /^doll /

    doll_name = msg.sub(/^doll /, '')
    return get_doll_pict(doll_name)
  end
end
