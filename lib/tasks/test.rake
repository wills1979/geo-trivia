desc "Fill the database tables with some sample data"
task({ :wiki_api_call => :environment }) do
  puts "Wiki API call task running"

  def remove_after(text, marker, include_marker: true)
    if include_marker
      text.sub(/#{Regexp.escape(marker)}.*/m, "")
    else
      text.sub(/#{Regexp.escape(marker)}/m) { |match| match }
          .sub(/(#{Regexp.escape(marker)})(.*)/m, '\1')
    end
  end

  wiki_url = "https://en.wikipedia.org/w/api.php"
  number_of_pages = 5
  search_radius_m = 5 * 1000
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

  pages.each do |page|
    page_id = page.fetch("pageid")

    page_params = {
      "action": "parse",
      "pageid": page_id.to_s,
      "format": "json",
      "prop": "text",
      "redirects": "true",
    }

    pages_data = JSON.parse(HTTP.get(wiki_url, params: page_params))

    # title
    title = pages_data.fetch("parse").fetch("title")

    # wikipedia_text
    html = pages_data.fetch("parse").fetch("text").fetch("*")
    sanitized_html = ActionView::Base.full_sanitizer.sanitize(html)
    wikipedia_text = remove_after(sanitized_html, "References[edit]")

    # latitude
    latitude = page.fetch("lat")

    # longitude
    longitude = page.fetch("lon")

    puts title
    puts latitude
    puts longitude

    puts "-------"
    sleep(0.1.seconds)
  end
end
