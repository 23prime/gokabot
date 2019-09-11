require 'spec_helper'

test_cases = [
  ['A91',  'https://cdn.wikiwiki.jp/to/w/dolls-fl/A91/::ref/A91.jpg'],
  ['damage A91', 'https://cdn.wikiwiki.jp/to/w/dolls-fl/A91/::ref/A91_damage.jpg'],
  ['Ak 5', 'https://cdn.wikiwiki.jp/to/w/dolls-fl/Ak%205/::ref/Ak%205.jpg'],
  ['03式', 'https://cdn.wikiwiki.jp/to/w/dolls-fl/03%E5%BC%8F/::ref/03%E5%BC%8F.jpg'],
  ['BGM',  '該当するドールが見つかりません'],
  ['hoge', '該当するドールが見つかりません']
]

describe DflSearch do
  let(:dfl_search) { DflSearch.new }

  test_cases.each do |test_case|
    msg = 'doll ' + test_case[0]
    exp_ans = test_case[1]

    it msg do
      ans = dfl_search.answer(msg)
      expect(exp_ans).to eq ans
    end
  end
end
