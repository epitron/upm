require 'open-uri'
require 'upm/colored'

class FreshportsSearch
  NUM_RESULTS = 20
  SEARCH_URL  = "https://www.freshports.org/search.php?query=%s&num=#{NUM_RESULTS}&stype=name&method=match&deleted=excludedeleted&start=1&casesensitivity=caseinsensitive"
  SVN_URL     = "svn://svn.FreeBSD.org/ports/head/%s/%s"

  def print(results)
    results.each do |path, desc, version|
      _, category, package = path.split("/")
      puts "<9>#{category}<8>/<11>#{package} <8>(<7>#{version}<8>)".colorize
      puts "  #{desc}"
      puts "  #{SVN_URL % [category, package]}".light_green
    end
  end

  def search!(query)
    puts "<8>* <7>Searching for <15>#{query}<7>...".colorize
    html = open(SEARCH_URL % query, &:read)
    puts
    results = html.scan(%r{<DT>\s*<BIG><B><a href="([^"]+)/">.+?</BIG>\s*<span class="[^"]+">([^<]+)</span><br>\s*<b>\s*([^<]+)\s*</b>}im)
    print(results)
  end
end

if __FILE__ == $0
  FreshportsSearch.new.search!("silver_searcher")
end
