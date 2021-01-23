describe Weather do
  base_msg_cases = %w[天気 今日の天気 明日の天気]

  before do
    @user_id = 'SAMPLE_USER_ID'
    @name = 'SAMPLE_NAME'
    @weather = Weather.new
    @default_city = Weather.get_default_city
    @capitalized_city_name = 'Tsukuba'
    @uncapitalized_city_name = 'kofu'
    @jp_city_name = '八戸'
    @unavailable_city = 'ほげほげ'
  end

  context "Default city: '#{@default_city}'" do
    base_msg_cases.each do |msg|
      it "[Base msg = #{msg}]" do
        ans = @weather.answer(msg, @user_id, @name)
        expect(ans).to include @default_city.capitalize
      end
    end
  end

  context "Changed city-1: '#{@capitalized_city_name}'" do
    base_msg_cases.each do |msg|
      it "[Base msg = #{msg}]" do
        msg = "#{msg} #{@capitalized_city_name}"
        ans = @weather.answer(msg, @user_id, @name)
        expect(ans).to include @capitalized_city_name.capitalize
      end
    end
  end

  context "Changed city-2: '#{@uncapitalized_city_name}'" do
    base_msg_cases.each do |msg|
      it "[Base msg = #{msg}]" do
        msg = "#{msg} #{@uncapitalized_city_name}"
        ans = @weather.answer(msg, @user_id, @name)
        expect(ans).to include @uncapitalized_city_name.capitalize
      end
    end
  end

  context "JP city name: '#{@jp_city_name}'" do
    base_msg_cases.each do |msg|
      it "[Base msg = #{msg}]" do
        msg = "#{msg} #{@jp_city_name}"
        ans = @weather.answer(msg, @user_id, @name)
        expect(ans).to include @jp_city_name.capitalize
      end
    end
  end

  context 'Unavailable city name' do
    base_msg_cases.each do |msg|
      it "[Base msg = #{msg}" do
        msg = "#{msg} #{@unavailable_city}"
        ans = @weather.answer(msg, @user_id, @name)
        expect(ans).to eq '分かりませ〜んｗ'
      end
    end
  end

  context 'Reset city to default' do
    it 'After changed' do
      msg = "天気 #{@capitalized_city_name}"
      ans = @weather.answer(msg, @user_id, @name)
      expect(ans).to include @capitalized_city_name.capitalize

      msg = '天気'
      ans = @weather.answer(msg, @user_id, @name)
      expect(ans).to include @default_city.capitalize
    end

    it 'After unavailable' do
      msg = "天気 #{@unavailable_city}"
      ans = @weather.answer(msg, @user_id, @name)
      expect(ans).to eq '分かりませ〜んｗ'

      msg = '天気'
      ans = @weather.answer(msg, @user_id, @name)
      expect(ans).to include @default_city.capitalize
    end
  end
end
