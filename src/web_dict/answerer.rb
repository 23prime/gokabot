require_relative 'wikipedia'
require_relative 'pixiv'
require_relative 'niconico'

module WebDict
  module Answerer
    WEB_DICTS = [
      Pixiv.new(),
      Niconico.new(),
      Wikipedia.new(),
      WikipediaEN.new(),
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

    def self.extract_keyword(msg)
      if NORMAL_QUESTION_REG =~ msg
        return $~[:query]
      end
      return nil
    end

    def self.search(keyword)
      threads = []
      WEB_DICTS.each do |web_dict|
        threads << Thread.start(keyword) do |keyword|
          next web_dict.browse(keyword)
        end
      end
      threads.each do |thread|
        result = thread.value()
        return result unless result.nil?
      end
      return nil
    end

    def self.answer(msg)
      keyword = extract_keyword(msg)
      return nil if keyword.nil?
      result = search(keyword)
      return NOT_FOUND_MESSAGES.sample() if result.nil?
      return result
    end
  end
end
