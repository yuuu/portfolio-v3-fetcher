require 'time'
require 'faraday'
require 'nokogiri'
require 'rss'
require 'sanitize'
require 'digest'

class SpeakerDeck
  def initialize(url)
    @url = url
  end

  def fetch
    res = Faraday.get(@url)
    return if res.status != 200

    rss = RSS::Parser.parse(res.body, true)
    rss.entries.each do |entry|
      entry_res = Faraday.get(entry.link.href)
      next if entry_res.status != 200

      doc = Nokogiri::HTML.parse(entry_res.body, entry_res.headers['charset'])
      image = doc.css('//meta[property="og:image"]/@content').to_s

      yield({
        id: Digest::MD5.hexdigest(entry.link.href),
        title: entry.title.content,
        body: Sanitize.clean(entry.content.content)[0...100] + '...',
        image: image,
        link: entry.link.href,
        publishedAt: entry.published.content.to_i,
        createdAt: Time.now.iso8601,
        updatedAt: Time.now.iso8601,
        _lastChangedAt: Time.now.to_i * 1000,
        _version: 1,
        __typename: 'Slide'
      })
    end
  end
end