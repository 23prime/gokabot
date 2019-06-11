require 'natto'

module Gokabou
  class NattoParser
    attr_accessor :nm

    def initialize()
      @nm = Natto::MeCab.new
    end

    def parse_text_array(texts)
      words = []
      index = 0

      texts.each do |text|
        words.push(Array[])

        @nm.parse(text) do |n|
          words[index].push(n.surface) unless n.surface.empty?
        end

        index += 1
      end

      return words
    end
  end

  class Marcov
    def self.gen_marcov_block(words)
      array = []

      # Insert nil begin and end
      words.unshift(nil)
      words.push(nil)

      # Add 3 words into each array
      bound = words.length - 3
      (0..bound).each do |i|
        array.push([words[i], words[i + 1], words[i + 2]])
      end

      return array
    end

    def self.find_blocks(array, target)
      blocks = []

      array.each do |block|
        if block[0] == target
          blocks.push(block)
        end
      end

      return blocks
    end

    def self.connect_blocks(array, dist)
      i = 0
      len = array.length

      unless len.zero?
        array[rand(len)].each do |word|
          dist.push(word) unless i.zero?
          i += 1
        end
      end

      return dist
    end

    def self.gen_text(array)
      result = []
      block = []

      # Find block which begin from nil
      block = find_blocks(array, nil)
      result = connect_blocks(block, result)

      # Loop until the end word of result is nil
      i = 0
      until result[result.length - 1].nil?
        block = find_blocks(array, result[result.length - 1])
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
      # twis = File.open('./docs/gokabou_tweets', 'r').read
      twis = File.open('./docs/gokabou_tweets', 'r').read.split("\n")
      twis = twis.slice(0, 1000)

      np = NattoParser.new
      wordss = np.parse_text_array(twis)

      wordss.map! { |words| Marcov.gen_marcov_block(words) }
      @words = wordss.flatten(1)
    end

    def gen_ans
      return Marcov.gen_text(@words)
    end
  end
end
