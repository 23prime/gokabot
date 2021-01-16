require 'dotenv/load'
require 'json'
require 'line/bot'

require_relative 'line/callback/reply_to_text'

class Callback
  def self.response(body)
    body_parsed = JSON.parse(body)
    msg = body_parsed['msg']
    user_id = body_parsed['user_id']
    user_name = body_parsed['user_name']

    return 400 if msg.nil? || user_id.nil? || user_name.nil?

    $reply_type = 'text'
    reply_to_text = Line::Callback::ReplyToText.new
    reply_text = reply_to_text.mk_reply_text(msg)

    reply_to_text.monitor(
      msg: msg,
      reply_text: reply_text,
      user_id: user_id,
      user_name: user_name
    )

    return reply_to_text.mk_reply_body(reply_text)
  end
end
