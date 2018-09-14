require "cgi"

class Tex

  BASE_URI = "https://chart.googleapis.com/chart?cht=tx&chl="
  TEX_ID = /^tex /i

  def request(text)
    BASE_URI+CGI.escape(text)
  end

  def answer(msg)
    if msg =~ TEX_ID
      return "日本語禁止" if msg =~/[^\x01-\x7E]/
      msg.slice!(TEX_ID)
      $reply_type = 'image'
      request(msg)
    end
  end

end
