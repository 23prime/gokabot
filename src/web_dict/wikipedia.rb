require_relative "web_dict"

module WebDict
  class Wikipedia < WebDict
    def uri
      return "https://ja.wikipedia.org/wiki/"
    end

    private 

    def first_elem_selector
      return 'div.mw-parser-output > p,' + 
        'div.mw-parser-output > ul,' + 
        'div.mw-parser-output > dl'
    end

    def change_elem(elem, count)
      remove_cites(elem)
      return super(elem, count)
    end

    def read_further?(elem, count)
      return ["p", "ul", "dl", "text"].include?(elem.name)
    end

    def remove_cites(elem)
      elem.css('sup.reference').each do |e|
        e.remove
      end
    end
  end
end