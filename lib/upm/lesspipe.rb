#
# Create scrollable output via less!
#
# This command runs `less` in a subprocess, and gives you the IO to its STDIN pipe
# so that you can communicate with it.
#
# Example:
#
#   lesspipe do |less|
#     50.times { less.puts "Hi mom!" }
#   end
#
# The default less parameters are:
# * Allow colour
# * Don't wrap lines longer than the screen
# * Quit immediately (without paging) if there's less than one screen of text.
#
# You can change these options by passing a hash to `lesspipe`, like so:
#
#   lesspipe(:wrap=>false) { |less| less.puts essay.to_s }
#
# It accepts the following boolean options:
#    :color  => Allow ANSI colour codes?
#    :wrap   => Wrap long lines?
#    :always => Always page, even if there's less than one page of text?
#    :tail   => Seek to the end of the stream
#    :search => <regexp> searches the output using the "/" operator
#
def lesspipe(*args)
  if args.any? and args.last.is_a?(Hash)
    options = args.pop
  else
    options = {}
  end

  output = args.first if args.any?

  # Don't page, just output to STDOUT
  if options[:disabled]
    if output
      puts output
    else
      yield STDOUT
    end
    return
  end

  params = []

  less_bin = File.which("less")

  if File.symlink?(less_bin) and File.readlink(less_bin)[/busybox$/]
    # busybox less only supports one option!
    params << "-S" unless options[:wrap]   == true
  else
    # authentic less
    params << "-R" unless options[:color]  == false
    params << "-S" unless options[:wrap]   == true
    params << "-F" unless options[:always] == true
    params << "-X"
    params << "-I"

    if regexp = options[:search]
      params << "+/#{regexp}"
    elsif options[:tail] == true
      params << "+\\>"
      $stderr.puts "Seeking to end of stream..."
    end
  end

  env = {
    "LESS_TERMCAP_mb" => "\e[01;31m",
    "LESS_TERMCAP_md" => "\e[01;37m",
    "LESS_TERMCAP_me" => "\e[0m",
    "LESS_TERMCAP_se" => "\e[0m",
    # "LESS_TERMCAP_so" => "\e[30;44m",      # highlight: black on blue
    "LESS_TERMCAP_so" => "\e[01;44;33m", # highlight: bright yellow on blue
    # "LESS_TERMCAP_so" => "\e[30;43m",    # highlight: black on yellow
    "LESS_TERMCAP_ue" => "\e[0m",
    "LESS_TERMCAP_us" => "\e[01;32m",
  }

  IO.popen(env, [less_bin, *params], "w") do |less|
    # less.puts params.inspect
    if output
      less.puts output
    else
      yield less
    end
  end

rescue Errno::EPIPE, Interrupt
  # less just quit -- eat the exception.
end

