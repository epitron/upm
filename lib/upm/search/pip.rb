#!/usr/bin/env ruby
###################################################################
gem 'xmlrpc';   require 'xmlrpc/client'
gem 'epitools'; require 'epitools/colored'
###################################################################

# For some reason you have to do this crazy thing so that it doesn't blow up when it sees a <nil/> tag
original_verbose, $VERBOSE = $VERBOSE, nil
XMLRPC::Config.const_set(:ENABLE_NIL_PARSER, true)
$VERBOSE = original_verbose

def pypi_api
  # PyPI XML-RPC API Reference:
  #   https://warehouse.pypa.io/api-reference/xml-rpc/
  #   https://wiki.python.org/moin/PyPIXmlRpc
  @pypi_api ||= XMLRPC::Client.new('pypi.python.org', '/pypi', 80)
end

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
  puts "    (searches all packages)"
  puts
  puts "  #{$PROGRAM_NAME} -i <gem name>"
  puts "    (shows info about a specific package)"
  puts
  exit 1
end

def print_pkg_info(pkg_name)
  versions = pypi_api.call("package_releases", pkg_name)
  # pp versions
  # versions.each do |version|
  #   info = pypi_api.call(:release_urls, pkg_name, version)
  #   pp info
  # end

  # info.values_at(*%w[upload_time filename size downloads])

  details = pypi_api.call(:release_data, pkg_name, versions.first)

  %w[name version home_page author author_email classifiers requires description].each do |field|
    puts "#{field}:".bright_white
    puts details[field].to_s.indent
  end
end

###################################################################

def print_search_results(query)
  # pkgs = pypi_api.call("search", {name: query, summary: query}, 'or')
  pkgs = pypi_api.call(:search, name: query)

 # {'name': 'spacy-arguing-lexicon',
 #  'summary': 'A spaCy extension wrapping around the arguing lexicon by MPQA',
 #  'version': '0.0.2',
 #  '_pypi_ordering': False},

  pkgs.reverse_each do |info|
    puts ("<8>=== " +
          "<11>#{info["name"]} " +
          "<7>(<3>v#{info["version"]}<7>)" +
          "<8>==============").colorize
    puts info["summary"].indent.bright_white unless info["summary"].empty?
    puts "    <3>https://pypi.org/project/#{info["name"]}/".colorize
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
  args.each { |arg| print_pkg_info(arg) }
else
  query = args.join("+")
  puts "<8>* <7>Searching pypi for <14>#{query.inspect}<7>...".colorize
  print_search_results(query)
end
