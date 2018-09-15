require "cgi"

class Tex

  BASE_URI = "https://chart.googleapis.com/chart?cht=tx&chs=200&chl="


  def request(text)
    BASE_URI+CGI.escape(text)
  end

  def answer(msg)
    if msg =~ /\$.+\$/ 
      return "日本語禁止" if msg =~/[^\x01-\x7E]/
      msg.chop!.slice!(0)
      return "長すぎだよ" if msg.length>=200
      $reply_type = 'image'
      request(msg)
    else
      nil
    end
  end

end
