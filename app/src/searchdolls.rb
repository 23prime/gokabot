require 'cgi'
require 'open-uri'

class DflSearch
  @@base_uri = 'https://cdn.wikiwiki.jp/to/w/dolls-fl/'

  def mk_url(doll_name, is_damage)
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

  def get_doll_pict(doll_name, is_damage)
    doll_name = CGI.escape(doll_name)
    doll_name.gsub!('+', '%20')
    url = mk_url(doll_name, is_damage)

    return '該当するドールが見つかりません' unless fetchable(url)
    $reply_type = 'image'
    return url
  end

  def answer(*msg_data)
    msg = msg_data[0]
    return unless msg =~ /^doll /

    is_damage = false
    doll_name = msg.sub(/^doll /, '')

    if doll_name =~ /damage/
      is_damage = true
      doll_name.sub!(/damage /, '')
    end
    get_doll_pict(doll_name, is_damage)
  end
end
