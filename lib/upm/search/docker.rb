#!/usr/bin/env ruby
###################################################################
require 'json'
require 'epitools/colored'
###################################################################

SEARCH_URL = 'https://hub.docker.com/v2/search/repositories/?page=1&query=%s'

###################################################################

class String
  def tighten; gsub(/[\t ]+/,' ').strip; end
  def any?; not empty?; end
  def indent(prefix="    ")
    each_line.map { |line| prefix + line }.join('')
  end
end

class Numeric
  def commatize(char=",")
    int, frac = to_s.split(".")
    int = int.gsub /(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/, "\\1#{char}\\2"

    frac ? "#{int}.#{frac}" : int
  end
end

###################################################################

# Handle ARGV

query = ARGV.join("+")

if query.empty?
  puts "Usage: #{__FILE__} <search query>"
  exit 1
end

# curl the results

puts "<8>* <7>Searching <15>hub.docker.com</15> for <14>#{query.inspect}<7>...".colorize

begin
  data = IO.popen(["curl", "-Ss", SEARCH_URL % query], &:read)
rescue Errno::ENOENT
  puts "Error: 'curl' isn't installed. You need this!"
  exit 1
end

json = JSON.parse(data)
puts "  <8>|_ <15>#{json["count"]} <7>results found...".colorize
puts

json["results"].sort_by { |result| result["pull_count"] }.each do |item|
  repo        = item["repo_name"]
  owner, name = repo.split("/")
  url         = "https://hub.docker.com/r/#{repo}/"
  desc        = item["short_description"]
  stars       = item["star_count"]
  pulls       = item["pull_count"]
  automated   = item["is_automated"]
  official    = item["is_official"]

  puts "<8>=== <11>#{name} <7>(<9>#{owner}<8>, <10>#{pulls.commatize} <2>pulls<8>, <13>#{stars.commatize}<5> stars<7>) <8>==============".colorize
  puts "    <15>#{desc}".colorize unless desc.empty?
  puts "    <3>#{url}".colorize
  puts
end
