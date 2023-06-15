require 'aws-sdk-dynamodb'

require_relative './qiita'
require_relative './zenn'
require_relative './fusic'
require_relative './speaker_deck'

SITES = [
  [Qiita, 'https://qiita.com/api/v2/users/Y_uuu/items?per_page=100', 'Article'],
  [Zenn, 'https://zenn.dev/y_uuu/feed', 'Article'],
  [Fusic, 'https://tech.fusic.co.jp/rss.xml', 'Article'],
  [SpeakerDeck, 'https://speakerdeck.com/yuuu.atom', 'Slide'],
]

class Time
  def iso8601
    strftime('%Y-%m-%dT%H:%M:%S.%LZ')
  end
end

def lambda_handler(event:, context:)
  client = Aws::DynamoDB::Client.new

  SITES.each do |klass, url, type|
    table_name = [type, ENV['AMPLIFY_APP_ID'], ENV['AMPLIFY_APP_ENV']].join('-')
    klass.new(url).fetch do |item|
      client.put_item(table_name:, item:)
    end
  end

  :success
end
