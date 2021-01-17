dao = Gokabou::GokabousDao.new
gm = Gokabou::GenMsg.new

gokabou_id = ENV['GOKABOU_USER_ID']
test_msg = 'test message'

describe 'Generate dict' do
  it 'Generate dict' do
    dict = gm.markov_dict
    count = dict.length

    p dict[-30, 30]
    p count
    expect(count).to be > 0
  end
end

describe 'Update dict' do
  it 'Success' do
    init_count = gm.markov_dict.length

    gm.update_dict(test_msg, gokabou_id)
    dict = gm.markov_dict
    count = dict.length

    p dict[-30, 30]
    p count
    expect(count).to be > init_count

    dao.delete(test_msg)
  end

  it 'Message includes URL' do
    init_count = gm.markov_dict.length

    gm.update_dict('url test message https://github.com/23prime/gokabot', gokabou_id)
    count = gm.markov_dict.length

    p count
    expect(count).to eq init_count
  end

  it 'Not Gokabou message' do
    init_count = gm.markov_dict.length

    gm.update_dict(test_msg, 'not gokabou id')
    count = gm.markov_dict.length

    p count
    expect(count).to eq init_count
  end

  it 'Message length over 300' do
    init_count = gm.markov_dict.length

    gm.update_dict(test_msg * 30, gokabou_id)
    count = gm.markov_dict.length

    p count
    expect(count).to eq init_count
  end

  it 'Message length under 5' do
    init_count = gm.markov_dict.length

    gm.update_dict('test', gokabou_id)
    count = gm.markov_dict.length

    p count
    expect(count).to eq init_count
  end
end
