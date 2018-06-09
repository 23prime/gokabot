require_relative "web_dict"

module WebDict
  class Niconico < WebDict
    def uri
      return "http://dic.nicovideo.jp/a/"
    end

    private 

    def first_elem_selector
      return 'div#article > p'
    end

    def skip_elem?(elem, count)
      return elem.name != "p"
    end
  end
end
