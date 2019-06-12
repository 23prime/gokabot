# coding:  utf-8
require 'csv'

class Pigeons

  def pick_mail()
    mails = CSV.read('./docs/yukarinmails.csv')
    mail = mails.sample
    sub = mail[1]
    body = mail[2]
    sub + "\n" + body
  end

  def answer(*msg_data)
    msg = msg_data[0]

    if msg =~ /鳩|ゆかり|はと/
      pick_mail
    else
      nil
    end
  end

end
