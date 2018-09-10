# coding:  utf-8
require 'csv'

class Pigeons

  def self.mail()
    mails = CSV.read('./docs/yukarinmails.csv')
    mail = mails.sample
    sub = mail[1]
    body = mail[2]
    sub + "\n" + body
  end

end
