#!/usr/bin/env ruby
require 'epitools/colored'
require 'epitools/core_ext/string'
require 'open-uri'
require 'oga'
require 'ostruct'

URL_ROOT   = "https://aur.archlinux.org"
SEARCH_URL = "#{URL_ROOT}/packages/?K=%s&O=0&SB=p&SO=d"

def search(query)
  # io  = open("aur.html")
  io  = URI.open(SEARCH_URL % query)
  doc = Oga.parse_html(io)

  doc.css("table.results tbody tr").map do |row|
    name, 
    version,
    votes,
    popularity,
    description,
    maintainer = row.css("td").map(&:text).map(&:strip)

    a = row.at_css("a.title")
    OpenStruct.new(
      name:        name,
      version:     version,
      votes:       votes.to_i,
      popularity:  popularity.to_f,
      description: description,
      maintainer:  maintainer,
      flagged:     row.css(".flagged").any?,
      url:         "#{URL_ROOT}/packages/#{name}/",
    )
  end
end

if ARGV.empty?
  puts "usage: rocksearch <query>"
  exit 1
end

query = ARGV.join(" ")

puts "<8>* <7>Searching for <15>#{query}<7>...".colorize

results = search(query)
results.sort_by! &:votes
results.each do |r|
  puts "<15>#{r.name} <#{r.flagged ? 12 : 11}>#{r.version} <8>(<10>#{r.votes}<7>/<2>#{r.popularity}<8>)".colorize
  puts r.description.wrapdent(2).white
  # puts "  <8>#{r.url}".colorize
  # puts "  <8>maintained by: <7>#{r.maintainer}".colorize
end
