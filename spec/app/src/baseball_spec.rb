require 'spec_helper'
describe 'answer something' do
  test_cases = %w[
    今日 昨日 明日 巨人 ソフトバンク \ 7月10日 6月24日 
    昨日\ 巨人 七月１２日
  ]

  nans = /((試合前|結果|中止|\d回(表|裏))\n.* - .*\n(\d|-) - (\d|-)\n\n){6}/
  exp_ans = [
    nans,
    /((結果|中止)\n.* - .*\n(-|\d) - (-|\d)\n\n){6}/,
    /(試合前\n.* - .*\n- - -\n\n){6}/,
    /^(試合前|結果|中止|\d回(表|裏))\n((.* - 巨人)|(巨人 - .*))\n(\d|-) - (\d|-)\n$/,
    /^(試合前|結果|中止|\d回(表|裏))\n((.* - ソフトバンク)|(ソフトバンク - .*))\n(\d|-) - (\d|-)\n$/,
    nans,
    /((試合前|結果|中止|\d回(表|裏))\n.* - .*\n(\d|-) - (\d|-)\n\n){2}\Z/,
    /^(結果|中止)\n((.* - 巨人)|(巨人 - .*))\n(\d|-) - (\d|-)\n$/,
    /^試合前\n.* - .*\n- - -\n\n/
  ]
  baseball_news = BaseballNews::Answerer.new
  test_cases.each_with_index do |test_case, i|
    it test_case do
      ans = baseball_news.answer('野球 ' + test_case)
      expect(ans).to eq('試合はありません').or match(exp_ans[i])
    end
  end
end
describe 'answer nothing' do
  exp_nil = [
    "野球 \n今日の野球 \nが楽しみ",
    '野球 アリゾナダイヤモンドバックス'
  ]
  baseball_news = BaseballNews::Answerer.new
  exp_nil.each do |test_case|
    it test_case do
      ans = baseball_news.answer(test_case)
      expect(ans).to be_nil
    end
  end
end
describe 'no game' do
  it 'nogame' do
    baseball_news = BaseballNews::Answerer.new
    ans = baseball_news.answer('野球 7月11日')
    expect(ans).to eq '試合はありません'
  end
end
