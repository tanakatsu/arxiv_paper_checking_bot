require 'net/http'
require 'uri'
require 'rexml/document'

class ArxivApi
  def search(keyword, max_results = 3)
    url = URI.parse("http://export.arxiv.org/api/query?search_query=all:#{keyword}&start=0&max_results=#{max_results}&sortBy=submittedDate&sortOrder=descending")
    res = Net::HTTP.get_response(url)

    xml = res.body
    doc = REXML::Document.new(xml)

    # https://medium.com/tech-batoora/xml-50488ec69b20
    entries = REXML::XPath.match(doc, '//feed/entry').map do |entry|
      {
        id: entry.elements['id'].text,
        updated: Date.parse(entry.elements['updated'].text),
        published: Date.parse(entry.elements['published'].text),
        title: entry.elements['title'].text,
        summary: entry.elements['summary'].text
      }
    end
    entries
  end
end
