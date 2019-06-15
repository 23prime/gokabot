require 'spec_helper'
require 'dotenv/load'

ud = Gokabou::UpdateDB.new

true_msg = 'テストテキスト'
short_msg = 'テスト'
long_msg = 'テスト' * 101

url_msg = 'テスト https://github.com/23prime/gokabot-line'
exist_msg = '今日の弁当'

true_id = ENV['GOKABOU_USER_ID']
false_id = 'U0123456789abcdefghijklmnopqrstuv'

test_case = [
  [true_msg,  true_id,  true, 1],
  [short_msg, true_id,  false, 0],
  [long_msg,  true_id,  false, 0],
  [true_msg,  false_id, false, 0],
  [url_msg,   true_id,  false, 0],
  [exist_msg, true_id,  false, 0]
]

describe 'Update and Delete' do
  len = ud.row_length

  test_case.each do |c|
    msg = c[0]
    user_id = c[1]
    pred = c[2]
    adding = c[3]

    it 'Update' do
      ud.update_db(msg, user_id)
      len += adding
      expect(ud.row_length).to eq len
      # expect(ud.updatable(msg, user_id)).to be pred
    end
  end

  it 'Delete' do
    ud.delete_data(true_msg)
    len -= 1
    expect(ud.row_length).to eq len
  end
end
