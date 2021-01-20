test_cases = %w[
  今期 今期のアニメ 今期のオススメ
  来期 来期のオススメ
  Sunday 日曜
  月曜のアニメ
  today 今日 今日のアニメ 今日のオススメ
  明日のおすすめ
]

describe Anime do
  let(:animes_ans) { Anime::Answerer.new }

  test_cases.each do |msg|
    it msg do
      puts '--------------------------------------------------'
      ans = animes_ans.answer(msg)

      puts '--------------------------------------------------'
      puts "> #{msg}"
      puts ans.to_s

      expect(ans).not_to be_empty
      puts '--------------------------------------------------'
    end
  end
end
