describe 'LINE Push test' do
  it 'Push message' do
    result = Line::Push.new.send_push_msg('test message', 'MY_USER_ID')
    expect(result).to eq 200
  end

  it 'Push random message' do
    result = Line::RamdomPush.new.send_push_msg('MY_USER_ID')
    expect(result).to eq 200
  end
end
