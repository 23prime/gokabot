RSpec.describe 'Answerer' do
  test_cases = [
    '明日の野球',
    '昨日の野球',
    '野球 巨人',
    '野球 ソフトバンク',
    '野球'
  ]

  exp_ans = [
    /(試合前\n.* - .*\n- - -\n\n){6}/,
    /((結果|中止)\n.* - .*\n(-|\d) - (-|\d)\n\n){6}/,
    /^(試合前|結果|中止|\d回(表|裏))\n((.* - 巨人)|(巨人 - .*))\n(\d|-) - (\d|-)\n$/,
    /^(試合前|結果|中止|\d回(表|裏))\n((.* - ソフトバンク)|(ソフトバンク - .*))\n(\d|-) - (\d|-)\n$/,
    /((試合前|結果|中止|\d回(表|裏))\n.* - .*\n(\d|-) - (\d|-)\n\n){6}/
  ]

  baseball_news = BaseballNews::Answerer.new
  test_cases.each_with_index do |test_case, i|
    it BaseballNews::Answerer do
      ans = baseball_news.answer(test_case)
      expect(ans).to match exp_ans[i] or eq '試合はありません'
    end
  end
  it 'return nil' do
    ans = baseball_news.answer("野球\n今日の野球\nが楽しみ")
    expect(ans).to eq nil
  end
end
