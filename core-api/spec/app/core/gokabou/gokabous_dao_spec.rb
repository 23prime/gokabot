dao = Gokabou::GokabousDao.new
test_msg = 'test msg'

describe 'CRUD test' do
  count = dao.count_all

  it 'Insert' do
    dao.insert(Date.today.strftime('%Y-%m-%d'), test_msg)
    count += 1
    expect(dao.count_all).to eq count
  end

  it 'Delete' do
    dao.delete(test_msg)
    count -= 1
    expect(dao.count_all).to eq count
  end
end
