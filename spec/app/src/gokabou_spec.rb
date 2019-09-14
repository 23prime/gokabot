require 'spec_helper'

test_cases1 = [
  %w[こん こん],
  %w[たけのこ たけのこ君ｐｒｐｒ],
  %w[ぬるぽ ｶﾞｯ],
  %w[行く 俺もイク！ｗ]
]

gkb_ans = Gokabou::Answerer.new

test_cases2 = [
  ['おみくじ', Gokabou::OMIKUJI],
  ['死ね', Gokabou::DEADS]
]

describe 'Gokabou' do
  test_cases1.each do |test_case|
    msg = test_case[0]
    exp_ans = test_case[1]

    it msg do
      ans = gkb_ans.answer(msg)
      expect(exp_ans).to eq ans
    end
  end

  test_cases2.each do |test_case|
    msg = test_case[0]
    ans_cands = test_case[1]

    it msg do
      ans = gkb_ans.answer(msg)
      expect(ans_cands).to include ans
    end
  end

  10.times do
    it 'マルコフ' do
      ans = gkb_ans.answer('ごかぼっと')

      puts '--------------------------------------------------'
      puts ans

      expect(ans).not_to be_empty
    end
  end
end
