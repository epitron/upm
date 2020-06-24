#!/usr/bin/env ruby
###################################################################
require 'json'
require 'epitools/colored'
require 'date'
###################################################################

GITHUB_SEARCH_URL   = 'https://api.github.com/search/repositories?q=%s&sort=stars&order=desc'
GITHUB_STARS_URL    = 'https://api.github.com/users/%s/starred?per_page=100'

###################################################################

class String
  def tighten; gsub(/[\t ]+/,' ').strip; end

  def any?; not empty?; end

  def indent(prefix="    ")
    each_line.map { |line| prefix + line }.join('')
  end

  def as_date
    ::DateTime.parse(self).new_offset(Time.now.zone)
  end

  def nice_date
    as_date.strftime("%Y-%m-%d %H:%M:%S")
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

def get_results(url, headers={})
  opts = headers.flat_map { |k,v| ["-H", "#{k}=#{v}"] }
  cmd  = ["curl", "-Ss", *opts, url]

  begin
    data = IO.popen(cmd, &:read)
    JSON.parse(data)
  rescue Errno::ENOENT
    puts "Error: 'curl' isn't installed. You need this!"
    exit 1
  end
end

###################################################################


# Handle ARGV
opts, args = ARGV.partition { |arg| arg[/^--?\w/] }

if args.empty?
  puts "Usage:"
  puts "  #{__FILE__} <search query>     => search respositories"
  puts "  (Note: The query can contain github search operators, like 'language:ruby')"
  puts
  puts "  #{__FILE__} -s <github user>   => show stars for a user"
  puts
  exit 1
end


if opts.include?("-s")

  # user's starred repos
  user = args.first
  url  = GITHUB_STARS_URL % user

  puts "<8>* <7>Showing github stars for <13>#{user.inspect}<7>...".colorize

  results = get_results(url) #, "Accept" => "application/vnd.github.v3.star+json")

else

  # query repos
  query = args.join("+")
  url   = GITHUB_SEARCH_URL % query

  puts "<8>* <7>Searching github.com for <14>#{query.inspect}<7>...".colorize

  results = get_results(url)["items"]

end

puts

# print the results
results.reverse.each do |item|
  # updated_at = item["updated_at"]
  name       = item["full_name"]
  desc       = item["description"]
  stars      = item["stargazers_count"].to_i
  size       = item["size"].to_i
  language   = item["language"]
  url        = item["clone_url"]

  puts "<8>=== <11>#{name} <7>(#{"<9>#{language}<8>, " if language}<10>#{stars.commatize} <2>stars<8>, <13>#{size.commatize}<5>KB<7>) <8>==============".colorize
  # puts "    <9>#{updated_at.nice_date}".colorize if updated_at
  puts "    <15>#{desc}".colorize if desc
  puts "    <3>#{url}".colorize
  puts
end
