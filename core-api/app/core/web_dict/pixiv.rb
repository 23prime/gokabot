require_relative "web_dict"

module WebDict
  class Pixiv < WebDict
    def uri
      return "https://dic.pixiv.net/a/"
    end

    private 

    def first_elem_selector
      return 'div.summary'
    end

    def skip_elem?(elem, index)
      return false
    end

    def read_further?(elem, count)
      return count <= 0
    end
  end
end
