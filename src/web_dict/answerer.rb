require_relative 'wikipedia'
require_relative 'pixiv'
require_relative 'niconico'

module WebDict
  class Answerer
    WEB_DICTS = [
      Niconico.new(),
      Pixiv.new(),
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

    def extract_keyword(msg)
      if NORMAL_QUESTION_REG =~ msg
        return $~[:query]
      end
      return nil
    end

    def initialize()
      @next_dicts = WEB_DICTS.shuffle
    end

    def search(keyword)
      threads = []
      @next_dicts = WEB_DICTS.shuffle if keyword != @prev_keyword
      @prev_keyword = keyword
      @next_dicts.each do |web_dict|
        threads << Thread.start(keyword) do |keyword|
          next web_dict.browse(keyword)
        end
      end
      threads.each_with_index do |thread, i|
        result = thread.value()
        unless result.nil?
          @next_dicts.delete_at(i)
          @next_dicts = WEB_DICTS.shuffle if @next_dicts.empty?
          return result 
        end
      end
      @next_dicts = WEB_DICTS.shuffle
      return nil
    end

    def answer(msg)
      keyword = extract_keyword(msg)
      return nil if keyword.nil?
      result = search(keyword)
      return NOT_FOUND_MESSAGES.sample() if result.nil?
      return result
    end
  end
end
