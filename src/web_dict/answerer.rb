require_relative 'wikipedia'
require_relative 'pixiv'
require_relative 'niconico'

module WebDict
  module Answerer
    WEB_DICTS = [
      Wikipedia.new(),
      Pixiv.new(),
      Niconico.new(),
    ]

    NOT_FOUND_MESSAGES = [
      "知りませ〜んｗｗｗｗｗ",
      "そんなことも知らねえのかテメェは"
    ]

    def self.search(keyword)
      WEB_DICTS.each do |web_dict|
        result = web_dict.browse(keyword)
        return result unless result.nil?
      end
      return nil
    end

    def self.answer(keyword)
      result = search(keyword)
      unless result.nil?
        return result
      end
      return NOT_FOUND_MESSAGES.sample()
    end
  end
end
