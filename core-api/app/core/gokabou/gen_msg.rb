require 'dotenv/load'
require 'natto'

require_relative '../../log_config'
require_relative '../../db/gokabous_dao'

module Gokabou
  class NattoParser
    attr_accessor :nm

    def initialize
      @nm = Natto::MeCab.new
    end

    def parse_sentence(sentence)
      words = []

      @nm.parse(sentence) do |n|
        words << n.surface unless n.surface.empty?
      end

      return words
    end
  end

  class Markov
    include LogConfig

    @@upper_bound_of_block_connection = 9

    def initialize
      @logger = @@logger.clone
      @logger.progname = self.class.to_s
    end

    def gen_markov_block(words)
      # Insert nil begin and end
      words.unshift(nil)
      words << nil

      # Add 3 words into each array
      array = []
      (0..words.length - 3).each do |i|
        array << [words[i], words[i + 1], words[i + 2]]
      end

      return array
    end

    def gen_text(all_blocks)
      # Select a first block randomly
      result = all_blocks.select { |b| b[0].nil? }.sample
      @logger.debug("Current block: #{result}")

      @@upper_bound_of_block_connection.times do
        break if result[-1].nil?

        block = all_blocks.select { |b| b[0] == result[-1] }.sample
        break if block.nil? # Not found next word
        @logger.debug("Current block: #{block}")
        result.concat(block[1..])
      end

      return result.join
    end
  end

  class GenMsg
    include LogConfig

    attr_accessor :markov_dict

    def initialize
      @logger = @@logger.clone
      @logger.progname = self.class.to_s

      @dao = GokabousDao.new
      @np = NattoParser.new
      @markov = Markov.new

      @markov_dict = mk_dict
    end

    def mk_dict
      return @dao
             .select_all_sentences.map { |s| @np.parse_sentence(s) }
             .map { |ws| @markov.gen_markov_block(ws) }
             .flatten!(1)
    end

    def update_dict(msg, user_id)
      return unless updatable(msg, user_id)

      @dao.insert(Date.today.strftime('%Y-%m-%d'), msg)
      @markov_dict = mk_dict
      @logger.info('Dictionary updated')
    end

    def sample
      return @markov.gen_text(@markov_dict)
    end

    private

    def updatable(msg, user_id)
      gid = ENV['GOKABOU_USER_ID']

      unless user_id == gid && msg.length > 4 && msg.length <= 300
        return false
      end

      return false if include_uri?(msg)
      return !@dao.select_all_sentences.include?(msg)
    end

    def include_uri?(msg)
      splited = msg.split(/[[:space:]]/)
      splited.map! { |str| str =~ URI::DEFAULT_PARSER.regexp[:ABS_URI] }
      return splited.any?
    end
  end
end
