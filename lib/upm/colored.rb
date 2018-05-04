#
# ANSI Colour-coding (for terminals that support it.)
#
# Originally by defunkt (Chris Wanstrath)
#   Enhanced by epitron (Chris Gahan)
#
# It adds methods to String to allow easy coloring.
#
# (Note: Colors are automatically disabled if your program is piped to another program,
#        ie: if STDOUT is not a TTY)
#
# Basic examples:
#
#   >> "this is red".red
#   >> "this is red with a blue background (read: ugly)".red_on_blue
#   >> "this is light blue".light_blue
#   >> "this is red with an underline".red.underline
#   >> "this is really bold and really blue".bold.blue
#
# Color tags:
# (Note: You don't *need* to close color tags, but you can!)
#
#   >> "<yellow>This is using <green>color tags</green> to colorize.".colorize
#   >> "<1>N<9>u<11>m<15>eric tags!".colorize
#   (For those who still remember the DOS color palette and want more terse tagged-colors.)
#
# Highlight search results:
#
#   >> string.gsub(pattern) { |match| "<yellow>#{match}</yellow>" }.colorize
#
# Forcing colors:
#
# Since the presence of a terminal is detected automatically, the colors will be
# disabled when you pipe your program to another program. However, if you want to
# show colors when piped (eg: when you pipe to `less -R`), you can force it:
#
#   >> Colored.enable!
#   >> Colored.disable!
#   >> Colored.enable_temporarily { puts "whee!".red }
#

require 'set'
require 'rbconfig'
require 'Win32/Console/ANSI' if RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
#require 'Win32/Console/ANSI' if RUBY_PLATFORM =~ /win32/

module Colored
  extend self

  @@is_tty = STDOUT.isatty

  COLORS = {
    'black'   => 30,
    'red'     => 31,
    'green'   => 32,
    'yellow'  => 33,
    'blue'    => 34,
    'magenta' => 35,
    'purple'  => 35,
    'cyan'    => 36,
    'white'   => 37
  }

  EXTRAS = {
    'clear'     => 0,
    'bold'      => 1,
    'light'     => 1,
    'underline' => 4,
    'reversed'  => 7
  }

  #
  # BBS-style numeric color codes.
  #
  BBS_COLOR_TABLE = {
    0   => :black,
    1   => :blue,
    2   => :green,
    3   => :cyan,
    4   => :red,
    5   => :magenta,
    6   => :yellow,
    7   => :white,
    8   => :light_black,
    9   => :light_blue,
    10  => :light_green,
    11  => :light_cyan,
    12  => :light_red,
    13  => :light_magenta,
    14  => :light_yellow,
    15  => :light_white,
  }

  VALID_COLORS = begin
    normal         = COLORS.keys
    lights         = normal.map { |fore| "light_#{fore}" }
    brights        = normal.map { |fore| "bright_#{fore}" }
    on_backgrounds = normal.map { |fore| normal.map { |back| "#{fore}_on_#{back}" } }.flatten

    Set.new(normal + lights + brights + on_backgrounds + ["grey", "gray"])
  end

  COLORS.each do |color, value|
    define_method(color) do
      colorize(self, :foreground => color)
    end

    define_method("on_#{color}") do
      colorize(self, :background => color)
    end

    define_method("light_#{color}") do
      colorize(self, :foreground => color, :extra => 'bold')
    end

    define_method("bright_#{color}") do
      colorize(self, :foreground => color, :extra => 'bold')
    end

    COLORS.each do |highlight, value|
      next if color == highlight

      define_method("#{color}_on_#{highlight}") do
        colorize(self, :foreground => color, :background => highlight)
      end

      define_method("light_#{color}_on_#{highlight}") do
        colorize(self, :foreground => color, :background => highlight, :extra => 'bold')
      end

    end
  end

  alias_method :gray, :light_black
  alias_method :grey, :light_black

  EXTRAS.each do |extra, value|
    next if extra == 'clear'
    define_method(extra) do
      colorize(self, :extra => extra)
    end
  end

  define_method(:to_eol) do
    tmp = sub(/^(\e\[[\[\e0-9;m]+m)/, "\\1\e[2K")
    if tmp == self
      return "\e[2K" << self
    end
    tmp
  end

  #
  # Colorize a string (this method is called by #red, #blue, #red_on_green, etc.)
  #
  # Accepts options:
  #   :foreground
  #       The name of the foreground color as a string.
  #   :background
  #       The name of the background color as a string.
  #   :extra
  #       Extra styling, like 'bold', 'light', 'underline', 'reversed', or 'clear'.
  #
  #
  # With no options, it uses tagged colors:
  #
  #    puts "<light_green><magenta>*</magenta> Hey mom! I am <light_blue>SO</light_blue> colored right now.</light_green>".colorize
  #
  # Or numeric ANSI tagged colors (from the BBS days):
  #    puts "<10><5>*</5> Hey mom! I am <9>SO</9> colored right now.</10>".colorize
  #
  #
  def colorize(string=nil, options = {})
    if string == nil
      return self.tagged_colors
    end

    if @@is_tty
      colored = [color(options[:foreground]), color("on_#{options[:background]}"), extra(options[:extra])].compact * ''
      colored << string
      colored << extra(:clear)
    else
      string
    end
  end

  #
  # Find all occurrences of "pattern" in the string and highlight them
  # with the specified color. (defaults to light_yellow)
  #
  # The pattern can be a string or a regular expression.
  #
  def highlight(pattern, color=:light_yellow, &block)
    pattern = Regexp.new(Regexp.escape(pattern)) if pattern.is_a? String

    if block_given?
      gsub(pattern, &block)
    else
      gsub(pattern) { |match| match.send(color) }
    end
  end

  #
  # An array of all possible colors.
  #
  def colors
    @@colors ||= COLORS.keys.sort
  end

  #
  # Returns the terminal code for one of the extra styling options.
  #
  def extra(extra_name)
    extra_name = extra_name.to_s
    "\e[#{EXTRAS[extra_name]}m" if EXTRAS[extra_name]
  end

  #
  # Returns the terminal code for a specified color.
  #
  def color(color_name)
    background = color_name.to_s =~ /on_/
    color_name = color_name.to_s.sub('on_', '')
    return unless color_name && COLORS[color_name]
    "\e[#{COLORS[color_name] + (background ? 10 : 0)}m"
  end

  #
  # Will color commands actually modify the strings?
  #
  def enabled?
    @@is_tty
  end

  alias_method :is_tty?, :enabled?

  #
  # Color commands will always produce colored strings, regardless
  # of whether the script is being run in a terminal.
  #
  def enable!
    @@is_tty = true
  end

  alias_method :force!, :enable!

  #
  # Enable Colored just for this block.
  #
  def enable_temporarily(&block)
    last_state = @@is_tty

    @@is_tty = true
    block.call
    @@is_tty = last_state
  end

  #
  # Color commands will do nothing.
  #
  def disable!
    @@is_tty = false
  end

  #
  # Is this string legal?
  #
  def valid_tag?(tag)
    VALID_COLORS.include?(tag) or
      (tag =~ /^\d+$/ and BBS_COLOR_TABLE.include?(tag.to_i) )
  end

  #
  # Colorize a string that has "color tags".
  #
  def tagged_colors
    stack = []

    # split the string into tags and literal strings
    tokens          = self.split(/(<\/?[\w\d_]+>)/)
    tokens.delete_if { |token| token.size == 0 }

    result        = ""

    tokens.each do |token|

      # token is an opening tag!

      if /<([\w\d_]+)>/ =~ token and valid_tag?($1)
        stack.push $1

      # token is a closing tag!

      elsif /<\/([\w\d_]+)>/ =~ token and valid_tag?($1)

        # if this color is on the stack somwehere...
        if pos = stack.rindex($1)
          # close the tag by removing it from the stack
          stack.delete_at pos
        else
          raise "Error: tried to close an unopened color tag -- #{token}"
        end

      # token is a literal string!

      else

        color = (stack.last || "white")
        color = BBS_COLOR_TABLE[color.to_i] if color =~ /^\d+$/
        result << token.send(color)

      end

    end

    result
  end

end unless Object.const_defined? :Colored

String.send(:include, Colored)
