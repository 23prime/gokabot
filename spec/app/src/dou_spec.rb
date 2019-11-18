require 'spec_helper'

ans_cases = [
  'どう？',
  'たしかに',
  'まあまあ',
  'そうかも',
  nil
]

describe 'Dou' do
  msg = 'ほげ'
  dou = Dou.new

  100.times do
    it msg do
      ans = dou.answer(msg)
      puts "Input: #{msg}    Answer: #{ans}"
      expect(ans_cases).to include ans
    end
  end
end
  
  