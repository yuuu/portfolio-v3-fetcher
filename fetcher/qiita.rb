require 'time'
require 'faraday'
require 'nokogiri'
require 'json'
require 'digest'

class Qiita
  def initialize(url)
    @url = url
  end

  def fetch
    res = Faraday.get(@url)
    return if res.status != 200

    items = JSON.parse(res.body)
    items.each do |item|
      item_res = Faraday.get(item['url'])
      next if res.status != 200

      doc = Nokogiri::HTML.parse(item_res.body, item_res.headers['charset'])
      image = doc.css('//meta[property="og:image"]/@content').to_s

      yield({
        id: Digest::MD5.hexdigest(item['url']),
        title: item['title'],
        body: item['body'][0...100] + '...',
        publishedAt: Time.parse(item['created_at']).to_i,
        imageUrl: image,
        link: item['url'],
        createdAt: Time.now.utc.iso8601,
        updatedAt: Time.now.utc.iso8601,
        _lastChangedAt: Time.now.to_i * 1000,
        _version: 1,
        __typename: 'Article',
        type: 'Article'
      })
    end
  end
end