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

    def change_elem(elem, count)
      remove_cites(elem)
      return elem
    end

    def remove_cites(elem)
      elem.css('sup > a.dic').each do |e|
        e.remove
      end
    end
  end
end
