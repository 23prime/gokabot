class CollectDebts
  def takenoko?(*msg_data)
    return 'お金返して' if msg_data[1] ~= /たけのこ/ || msg_data[2] == MY_USER_ID
  end

  def answer(*msg_data)
    return takenoko?(msg_data)
  end
end
