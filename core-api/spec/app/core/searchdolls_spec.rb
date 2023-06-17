describe DflSearch do
  subject { described_class.new.answer(msg) }

  context 'Success' do
    let(:msg) { 'doll Ak 5' }

    before do
      stub_request(:get, /cdn.wikiwiki.jp/).to_return(status: 200)
    end

    it do
      expect(subject).to eq 'https://cdn.wikiwiki.jp/to/w/dolls-fl/Ak%205/::ref/Ak%205.jpg'
    end
  end

  context 'Unfetchable URL' do
    let(:msg) { 'doll foo' }

    before do
      stub_request(:get, /cdn.wikiwiki.jp/).to_return(status: 404)
    end

    it do
      expect(subject).to eq '該当するドールが見つかりません'
    end
  end

  context 'Invalid message' do
    let(:msg) { 'foo' }

    it do
      expect(subject).to eq nil
    end
  end
end
