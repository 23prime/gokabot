require 'spec_helper'
require 'dotenv/load'

ud = Gokabou::UpdateDB.new

true_id = ENV['GOKABOU_USER_ID']
false_id = 'U0123456789abcdefghijklmnopqrstuv'

true_msg = 'テストテキスト'
short_msg = 'テスト'
long_msg = 'テスト' * 101

url_msg = 'テスト https://github.com/23prime/gokabot-line'
exist_msg = '今日の弁当'

test_case = [
  [true_msg,  true_id,  true],
  [short_msg, true_id,  false],
  [long_msg,  true_id,  false],
  [true_msg,  false_id, false],
  [url_msg,   true_id,  false],
  [exist_msg, true_id,  false]
]

describe 'Updatable' do
  test_case.each do |c|
    msg = c[0]
    user_id = c[1]
    pred = c[2]

    it msg do
      expect(ud.updatable(msg, user_id)).to be pred
    end
  end
end
