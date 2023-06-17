require 'webmock/rspec'

describe 'LINE Push test' do
  before do
    stub_request(:post, Line::Push::URL).to_return(status: 200)
  end

  it 'Push message' do
    result = Line::Push.new.send_msg('test message', 'Uexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    expect(result).to eq 200
  end

  it 'Push random message' do
    result = Line::RamdomPush.new.send_msg('Uexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    expect(result).to eq 200
  end
end
