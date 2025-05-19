desc "Fill the database tables with some sample data"
task({ :wiki_api_call => :environment }) do
  puts "Wiki API call task running"

  wiki_url = "https://en.wikipedia.org/w/api.php"
  number_of_pages = 5
  search_radius_m = 5*1000
  wiki_params = {
    "format": "json",
    "list": "geosearch",
    "gscoord": "37.7891838|-122.4033522",
    "gslimit": "#{number_of_pages}",
    "gsradius": "#{search_radius_m}",
    "action": "query",
  }
  
  wiki_response = HTTP.get(wiki_url, params: wiki_params)

  parsed_wiki_response = JSON.parse(wiki_response)

  pages = parsed_wiki_response.fetch("query").fetch("geosearch")
  
  # create list of page_ids and join
  page_ids = []
  pages.each do |page|
    page_ids << [page.fetch("pageid")]
  end

  content_url = "https://en.wikipedia.org/w/api.php?action=query&pageids=#{page_ids.join("|")}&format=json&prop=extracts&explaintext=true"

  pages_data = JSON.parse(HTTP.get(content_url)).fetch("query").fetch("pages")

  pages_data.each do |page_object|
    id = page_object.first
    pp page_object.first
    # page_data = page_object.fetch("pageid")
    # pp page_data.fetch("title")
    # pp page_data.fetch("extract")

    # pp page_data
  end

end
