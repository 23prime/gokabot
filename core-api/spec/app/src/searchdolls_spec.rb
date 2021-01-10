require 'spec_helper'

test_cases = [
  ['Ak 5', 'https://cdn.wikiwiki.jp/to/w/dolls-fl/Ak%205/::ref/Ak%205.jpg'],
  ['03式', 'https://cdn.wikiwiki.jp/to/w/dolls-fl/03%E5%BC%8F/::ref/03%E5%BC%8F.jpg'],
  %w[BGM 該当するドールが見つかりません],
  %w[hoge 該当するドールが見つかりません]
]

describe DflSearch do
  let(:dfl_search) { DflSearch.new }

  test_cases.each do |test_case|
    msg = 'doll ' + test_case[0]
    exp_ans = test_case[1]

    it msg do
      ans = dfl_search.answer(msg)
      expect(ans).to eq exp_ans
    end
  end
end
