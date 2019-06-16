describe 'Reply test' do
  let(:msg) { 'ぬるぽ' }

  let(:user_id) { 'U0123456789abcdefghijklmnopqrstuv' }

  let(:name) { 'たけのこ' }

  it 'NullPointer' do
    reply = mk_reply(msg, user_id, name)
    reply_msg = reply[:text]
    expect(reply_msg).to eq 'ｶﾞｯ'
  end
end
