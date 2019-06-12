require 'natto'

module Gokabou
  class NattoParser
    attr_accessor :nm

    def initialize
      @nm = Natto::MeCab.new
    end

    def parse_text_array(texts)
      wordses = []

      texts.each do |text|
        words = []

        @nm.parse(text) do |n|
          words << n.surface unless n.surface.empty?
        end

        wordses << words
      end

      return wordses
    end
  end

  class Marcov
    def self.gen_marcov_block(words)
      # Insert nil begin and end
      words.unshift(nil)
      words << nil

      # Add 3 words into each array
      bound = words.length - 3
      array = []

      (0..bound).each do |i|
        array << [words[i], words[i + 1], words[i + 2]]
      end

      return array
    end

    def self.find_blocks(array, target)
      blocks = []

      array.each do |block|
        blocks << block if block[0] == target
      end

      return blocks
    end

    def self.connect_blocks(array, dist)
      i = 0
      len = array.length

      unless len.zero?
        array[rand(len)].each do |word|
          dist << word unless i.zero?
          i += 1
        end
      end

      return dist
    end

    def self.gen_text(array)
      # Find block which begin from nil
      block = find_blocks(array, nil)
      result = connect_blocks(block, [])

      # Loop until the end word of result is nil
      i = 0

      until result[-1].nil?
        block = find_blocks(array, result[-1])
        result = connect_blocks(block, result)
        i += 1
        break if i > 100
      end

      text = result.join
      return text
    end
  end

  class Gokabou
    def initialize
      twis = File.open('./docs/gokabou_tweets', 'r').read.split("\n")
      np = NattoParser.new
      wordses = np.parse_text_array(twis)

      wordses.map! { |words| Marcov.gen_marcov_block(words) }
      @words = wordses.flatten(1)
    end

    def gen_ans
      return Marcov.gen_text(@words)
    end
  end
end
