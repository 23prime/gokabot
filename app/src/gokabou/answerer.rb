require 'dotenv/load'
require_relative './gen_msg.rb'
require_relative './update_db.rb'

module Gokabou
  VERSION = '1.0.0'
  HELP = File.open('./docs/help', 'r').read
  OMIKUJI = File.open('./docs/omikuji', 'r').read.split("\n")
  DEADS = File.open('./docs/deads', 'r').read.split("\n")
  NEW_YEARS = File.open('./docs/new_years', 'r').read.split("\n")

  class NewYear
    def sample
      return NEW_YEARS.sample if @month == 1 && @day == 1
    end
  end

  class Answerer
    def initialize
      d = Time.now
      @month = d.month
      @day = d.day

      @ud = UpdateDB.new
      @gen = GenMsg.new(@ud.all_sentences)

      @answers = [
        [/\Aこん(|です)(|ｗ|w)\Z/i, ['こん']],
        [/死ね|死んで/, DEADS],
        [/行く/, ['俺もイク！ｗ']],
        [/\Agokabot[[:blank:]]+(-v|--version)\Z/, [VERSION]],
        [/\Agokabot[[:blank:]]+(-h|--help)\Z/, [HELP]],
        [/\Aおみくじ\Z/, OMIKUJI],
        [/たけのこ(君|くん|さん|ちゃん|)/, ['たけのこ君ｐｒｐｒ']],
        [/\Aぬるぽ\Z/, ['ｶﾞｯ']],
        [/あけ|明け|おめ|こん|おは|happy|new|year|2019/i, NewYear.new],
        [/ごかぼっと|gokabot|ごかぼう|gokabou|\Aヒゲ\Z|\Aひげ\Z/, @gen]
      ]
    end

    def include_uri?(msg)
      splited = msg.split(/[[:space:]]/)
      splited.map! { |str| str =~ URI::DEFAULT_PARSER.regexp[:ABS_URI] }

      return splited.any?
    end

    def updatable(msg, user_id)
      gid = ENV['GOKABOU_USER_ID']

      unless user_id == gid && msg.length > 4 && msg.length <= 300
        return false
      end

      return false if include_uri?(msg)
      return !@ud.all_sentences.include?(msg)
    end

    def answer(*msg_data)
      msg = msg_data[0]
      user_id = msg_data[1]

      if updatable(msg, user_id)
        @ud.update_db(msg)
        @gen.update_dict(msg)
      end

      @answers.each do |reg_ans|
        reg = reg_ans[0]
        if msg =~ reg
          ans = reg_ans[1].sample
          return ans unless ans.nil?
        end
      end
    end
  end
end
