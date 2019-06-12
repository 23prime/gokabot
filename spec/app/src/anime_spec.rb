require 'spec_helper'

test_cases = %w[
  今期 今期のアニメ 今期のオススメ
  来期
  Sunday 日曜
  月曜のアニメ
  today 今日 今日のアニメ 今日のオススメ
  明日のおすすめ
]

animes_ans = Anime::Answerer.new

describe 'Anime' do
  test_cases.each do |msg|
    it msg do
      ans = animes_ans.answer(msg)

      puts "> #{msg}"
      puts "#{ans.slice(0, 100)}..."
      puts '--------------------------------------------------'

      expect(ans).not_to be_empty
    end
  end
end
