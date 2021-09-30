test_msg = 'test msg'

describe 'CRUD test' do
  count = Gokabous.all.count

  it 'Insert' do
    Gokabous.insert(Date.today.strftime('%Y-%m-%d'), test_msg)
    count += 1
    expect(Gokabous.all.count).to eq count
  end

  it 'Delete' do
    Gokabous.delete(test_msg)
    count -= 1
    expect(Gokabous.all.count).to eq count
  end
end
