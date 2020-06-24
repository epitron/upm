#!/usr/bin/env ruby
###################################################################
# require 'oga'
require 'json'
require 'date'
require 'epitools/colored'
###################################################################

# More API URLs: https://guides.rubygems.org/rubygems-org-api/
RUBYGEMS_SEARCH_URL = "https://rubygems.org/api/v1/search.json?query=%s"
RUBYGEMS_INFO_URL   = "https://rubygems.org/api/v1/versions/%s.json"

###################################################################

class String
  def tighten; gsub(/[\t ]+/,' ').strip; end
  def any?; not empty?; end

  def indent(prefix="    ")
    gsub(/^/m, prefix)
  end

  def commatize
    gsub /(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/, "\\1,\\2"
  end    
end

class Integer
  def commatize; to_s.commatize; end
end

###################################################################

def help!
  puts "usage:"
  puts "  $ #{$PROGRAM_NAME} <search query>"
  puts "    (searches all gems)"
  puts
  puts "  #{$PROGRAM_NAME} -i <gem name>"
  puts "    (shows info about a specific gem)"
  puts
  exit 1
end

###################################################################

def extract_info(root)
  result = []

  classes = root["class"].split.map do |s|
    if s =~ /^gems__gem__(.+)/
      $1.gsub("__", "_")
    else
      nil
    end
  end.compact

  text = root.inner_text.tighten
  
  if classes.any? and text.any? 
    result << [classes.first, text]
  end

  root.children.each do |node|
    next unless node.is_a? Oga::XML::Element
    result += extract_info(node)
  end

  result
end

###################################################################

def curl(url)
  html = IO.popen(["curl", "-Ss", url], &:read)
rescue Errno::ENOENT
  puts "Error: 'curl' isn't installed. You need this!"
  exit 1
end

def curl_json(url)
  JSON.parse(curl(url))
end

def format_date(date)
  date.strftime("%b %d, %Y")
end

def nicedate(date)
  format_date DateTime.parse(date)
end

def print_gem_info(gem_name)
  #   {
  #     "authors": "epitron",
  #     "built_at": "2015-07-12T00:00:00.000Z",
  #     "created_at": "2015-07-12T16:46:50.411Z",
  #     "description": "Wrap all known command-line package tools with a consistent and pretty interface.",
  #     "downloads_count": 1346,
  #     "metadata": {
  #     },
  #     "number": "0.0.0",
  #     "summary": "Universal Package Manager",
  #     "platform": "ruby",
  #     "rubygems_version": ">= 0",
  #     "ruby_version": ">= 0",
  #     "prerelease": false,
  #     "licenses": [
  #       "WTFPL"
  #     ],
  #     "requirements": [

  #     ],
  #     "sha": "6a0d30f765c410311b9c666f78624b6339107bf8cf24a8040bbddf05035a7b3d"
  #   }
  # ]
  versions = curl_json(RUBYGEMS_INFO_URL % gem_name)
  versions.sort_by! { |v| v["created_at"] }

  info    = versions.last
  summary = info["summary"]
  desc    = info["description"]
  desc    = nil if summary == desc

  colorize_pair = proc { |field, value| "<7>#{field}: <15>#{value}".colorize }

  puts "<8>== <11>#{gem_name} <2>v<10>#{info["number"]} <8>(<7>#{nicedate(info["created_at"])}) <8>====".colorize
  puts
  puts colorize_pair["summary", summary]
  puts colorize_pair["authors", info["authors"]]
  puts colorize_pair["licenses", info["licenses"].join(", ")]
  puts colorize_pair["requirements", info["requirements"].inspect] if info["requirements"].any?
  puts colorize_pair["description", desc] if desc
  puts
  puts "----------------------".grey
  puts "  Previous releases:"
  puts "----------------------".grey
  versions.each do |version|
    date = nicedate version["created_at"]
    dls = version["downloads_count"].commatize
    puts "<9>#{date}: <2>v<10>#{version["number"]} <8>(<11>#{version["platform"]}<7>, <13>#{dls} <5>downloads<8>)".colorize
  end
end


def print_search_results(query)
  # {
  #   "name": "cucumber_analytics",
  #   "downloads": 65305,
  #   "version": "1.6.0",
  #   "version_downloads": 1903,
  #   "platform": "ruby",
  #   "authors": "Eric Kessler",
  #   "info": "Static analysis of Cucumber tests made easy.",
  #   "licenses": [
  #     "MIT"
  #   ],
  #   "metadata": {
  #   },
  #   "sha": "e8f47fb5de750a2ac201172baf2a1f16fdb2b0ca84f6fff2e73003d38f1bcea5",
  #   "project_uri": "https://rubygems.org/gems/cucumber_analytics",
  #   "gem_uri": "https://rubygems.org/gems/cucumber_analytics-1.6.0.gem",
  #   "homepage_uri": "https://github.com/enkessler/cucumber_analytics",
  #   "wiki_uri": null,
  #   "documentation_uri": "http://www.rubydoc.info/gems/cucumber_analytics/1.6.0",
  #   "mailing_list_uri": null,
  #   "source_code_uri": null,
  #   "bug_tracker_uri": null,
  #   "changelog_uri": null,
  #   "dependencies": {
  #     "development": [
  #       {
  #         "name": "coveralls",
  #         "requirements": "< 1.0.0"
  #       },
  #       ...
  #     ],
  #     "runtime": [
  #       {
  #         "name": "gherkin",
  #         "requirements": "< 3.0"
  #       },
  #       ...
  #     ]
  #   }
  # }

  gems = curl_json(RUBYGEMS_SEARCH_URL % query)

  gems.sort_by! { |info| info["downloads"] }

  gems.each do |info|
    puts ("<8>=== " + 
          "<11>#{info["name"]} " + 
          "<7>(<3>v#{info["version"]}<8>, " + 
          "<13>#{info["downloads"].commatize} <5>downloads<7>) " + 
          "<8>==============").colorize
    puts info["info"].indent.bright_white
    puts "    <3>https://rubygems.org/gems/#{info["name"]}".colorize
    puts
  end
end


###################################################################
# Handle ARGV

opts, args = ARGV.partition { |arg| arg[/^-\w/] }

if (args.empty? and opts.empty?) or opts.include?("--help")
  help!
  exit 1
end

if opts.include?("-i")
  args.each { |arg| print_gem_info(arg) }
else
  query = args.join("+")
  puts "<8>* <7>Searching rubygems.org for <14>#{query.inspect}<7>...".colorize
  print_search_results(query)
end
