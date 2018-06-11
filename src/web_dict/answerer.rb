require_relative 'wikipedia'
require_relative 'pixiv'
require_relative 'niconico'

module WebDict
  class Answerer
    WEB_DICTS = [
      Pixiv.new(),
      Niconico.new(),
      Wikipedia.new(),
      Wikipedia_en.new(),
    ]

    NOT_FOUND_MESSAGES = [
      "知りませ〜んｗｗｗｗｗ",
      "そんなことも知らねえのかテメェは"
    ]

    END_REG = /([\.\?．。？]|$)/
    INTERROG_REG = /(って[\?？]|とは#{END_REG}|((とは|って)(なに|何|誰|だれ|どこ|((なん|何|誰|だれ|どこ)(なの|だよ|だょ|ですか|のこ))))#{END_REG})/
    DELIM_REG = /[\.,．。，、]/
    WORD_REG = /(([^\n\r\f\.,．。，、]+#{DELIM_REG}*)|#{DELIM_REG}+)/
    NORMAL_QUESTION_REG = /(?<query>#{WORD_REG})#{INTERROG_REG}/
    PREV_QUESTION_REG = /^#{INTERROG_REG}/

    def reacts?(msg)
      if NORMAL_QUESTION_REG =~ msg
        @query = $~[:query]
        return true
      end
      return false
    end

    attr_reader :query

    def search(keyword)
      WEB_DICTS.each do |web_dict|
        result = web_dict.browse(keyword)
        return result unless result.nil?
      end
      return nil
    end

    def answer(keyword = nil)
      keyword = query if keyword.nil?
      return NOT_FOUND_MESSAGES.sample() if keyword.nil?
      result = search(keyword)
      return NOT_FOUND_MESSAGES.sample() if result.nil?
      @query = nil
      return result
    end
  end
end
