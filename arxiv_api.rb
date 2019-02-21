require 'net/http'
require 'uri'
require 'rexml/document'

class ArxivApi
  def search(keywords, max_results = 3)
    query = build_query(keywords)
    url = URI.parse("http://export.arxiv.org/api/query?search_query=#{query}&start=0&max_results=#{max_results}&sortBy=submittedDate&sortOrder=descending")
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

  private

  def build_query(keywords)
    cat = 'all'
    keywords.inject('') do |param, kw|
      if param.empty?
        param = "#{cat}:#{kw}"
      elsif kw.start_with?('+')
        param = "#{param}+OR+#{cat}:#{kw[1..kw.size]}"
      elsif kw.start_with?('!')
        param = "#{param}+ANDNOT+#{cat}:#{kw[1..kw.size]}"
      else
        param = "#{param}+AND+#{cat}:#{kw}"
      end
      param
    end
  end
end
