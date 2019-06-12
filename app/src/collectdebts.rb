class CollectDebts
  def takenoko?(msg_data)
    return 'お金返して' if msg_data[1] == ENV['MY_USER_ID'] || (msg_data[2] =~ /たけのこ/)
  end

  def answer(*msg_data)
    return takenoko?(msg_data)
  end
end
