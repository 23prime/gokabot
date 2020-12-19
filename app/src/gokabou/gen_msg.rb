require 'natto'

require './app/log_config'

module Gokabou
  class NattoParser
    attr_accessor :nm, :dict

    def initialize(sentences)
      @nm = Natto::MeCab.new
      @dict = sentences.map { |sentence| parse_sentence(sentence) }
    end

    def parse_sentence(sentence)
      words = []

      @nm.parse(sentence) do |n|
        words << n.surface unless n.surface.empty?
      end

      return words
    end
  end

  class Marcov
    include LogConfig

    @@logger = @@logger.clone
    @@logger.progname = self.class.to_s

    @@upper_bound_of_block_connection = 9

    def self.gen_marcov_block(words)
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

    def self.gen_text(all_blocks)
      # Select a first block randomly
      result = all_blocks.select { |b| b[0].nil? }.sample
      @@logger.debug("Current block: #{result}")

      @@upper_bound_of_block_connection.times do
        break if result[-1].nil?

        block = all_blocks.select { |b| b[0] == result[-1] }.sample
        break if block.nil? # Not found next word
        @@logger.debug("Current block: #{block}")
        result.concat(block[1..])
      end

      return result.join
    end
  end

  class GenMsg
    include LogConfig

    attr_accessor :marcov_dict

    def initialize(sentences)
      @logger = @@logger.clone
      @logger.progname = self.class.to_s

      @np = NattoParser.new(sentences)

      @marcov_dict = @np.dict.map { |words| Marcov.gen_marcov_block(words) }
      @marcov_dict.flatten!(1)
    end

    def update_dict(sentence)
      words = @np.parse_sentence(sentence)
      blocks = Marcov.gen_marcov_block(words)

      blocks.each do |block|
        @marcov_dict << block
      end

      @logger.info('Dictionary updated')
    end

    def sample
      return Marcov.gen_text(@marcov_dict)
    end
  end
end
