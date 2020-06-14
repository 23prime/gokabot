require 'net/http'
require 'json'

require './app/log_config'

class Push
  include LogConfig

  @@logger = @@logger.clone
  @@logger.progname = 'Push'

  def self.send_push_msg(msg, target)
    @@logger.info("Send push message: '#{msg}' to '#{target}'")

    target_id = ENV[target]

    if target_id.nil?
      @@logger.error('Push target is nil.')
      return 401
    end

    uri = URI.parse('https://api.line.me/v2/bot/message/push')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === 'https'
    response = http.post(uri.path, body(msg, target_id), headers)

    @@logger.info("Push response status: #{response.code}")
    @@logger.info("Push response body: #{response.body}")

    return response.code
  end

  def self.headers
    return {
      'Content-type' => 'application/json',
      'Authorization' => 'Bearer ' + ENV['LINE_CHANNEL_TOKEN']
    }
  end

  def self.body(msg, target_id)
    return {
      'to' => target_id,
      'messages' => [
        {
          'type' => 'text',
          'text' => msg
        }
      ]
    }.to_json
  end
end
