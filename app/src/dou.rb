class Dou
  ANSWERS = [
    'どう？',
    'たしかに',
    'まあまあ',
    'そうかも'
  ]

  def answer(*msg_data)
    ans = nil
    len = ANSWERS.length
    n = rand(len * 10)

    ans = ANSWERS[n] if n < len
    return ans
  end
end