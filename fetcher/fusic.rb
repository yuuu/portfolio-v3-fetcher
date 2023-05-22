require 'time'
require 'faraday'
require 'nokogiri'
require 'rss'
require 'sanitize'
require 'digest'

class Fusic
  def initialize(url)
    @url = url
  end

  def fetch
    res = Faraday.get(@url)
    return if res.status != 200

    rss = RSS::Parser.parse(res.body, true)
    rss.items.each do |item|
      item_res = Faraday.get(item.link)
      next if item_res.status != 200

      doc = Nokogiri::HTML.parse(item_res.body, item_res.headers['charset'])
      author = doc.css('div h2.name')
      next unless author.text.match?('yuuu')

      image = doc.css('//meta[property="og:image"]/@content').to_s
      body = Sanitize.clean(doc.css('main.content').to_s)[0...100] + '...'

      yield({
        id: Digest::MD5.hexdigest(item.link),
        title: item.title,
        body: body,
        imageUrl: image,
        link: item.link,
        publishedAt: item.date.to_i,
        createdAt: Time.now.utc.iso8601,
        updatedAt: Time.now.utc.iso8601,
        _lastChangedAt: Time.now.to_i * 1000,
        _version: 1,
        __typename: 'Article'
      })
    end
  end
end
