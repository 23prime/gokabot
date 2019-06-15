require 'spec_helper'

ud = Gokabou::UpdateDB.new
gm = Gokabou::GenMsg.new(ud.all_sentences)


describe 'GenMsg' do
  dict0 = gm.marcov_dict
  len0 = dict0.length

  it 'Generate' do
    p dict0[-30, 30]
    p len0
    expect(len0).to be > 0
  end

  it 'Update' do
    gm.update_dict('女の子にパンツマンって呼ばれてる常連とワイワイしすぎて14k飛んだ')
    dict = gm.marcov_dict
    len = gm.marcov_dict.length

    p dict[-30, 30]
    p len
    expect(len).to be > len0
  end
end
