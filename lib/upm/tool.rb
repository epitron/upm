
# os:<pkg> -- automatically select the package manager for the current unix distribution
# deb:<pkg> (or d: u:)
# rpm:<pkg> (or yum: y:)
# bsd:<pkg> (or b:)
# ruby:<pkg> (or r: gem:)
# python:<pkg>,<pkg> (or py: p: pip:)

module UPM

  class Tool

    COMMAND_HELP = {
      "install"          => "install a package",
      "remove/uninstall" => "remove a package",
      "build"            => "compile a package from source and install it",
      "search"           => "using the fastest known API or service",
      "list"             => "list installed packages (or search their names if extra arguments are supplied)",
      "info"             => "show metadata about a package",
      "update/sync"      => "retrieve the latest package list or manifest",
      "upgrade"          => "install new versions of all packages",
      "pin"              => "pinning a package means it won't be automatically upgraded",
      "rollback"         => "revert to an earlier version of a package (including its dependencies)",
      "log"              => "show history of package installs",
      "packagers"        => "detect installed package managers, and pick which ones upm should wrap",
      "mirrors/sources"  => "manage remote repositories and mirrors",
      "verfiy"           => "verify the integrity of installed files",
      "clean"            => "clear out the local package cache",
      "monitor"          => "ad-hoc package manager for custom installations (like instmon)",
      "keys"             => "keyrings and package authentication",
      "default"          => "configure the action to take when no arguments are passed to 'upm' (defaults to 'os:update')",
    }

    ALIASES = {
      "file"    => "files",
      "sync"    => "update",
      "sources" => "mirrors",
      "show"    => "info",
    }

    @@tools = {}
    def self.tools; @@tools; end

    def self.register_tools!
      Dir["#{__dir__}/tools/*.rb"].each { |lib| require_relative(lib) }
    end

    def self.os_release
      @os_release ||= begin
        open("/etc/os-release") do |io|
          io.read.scan(/^(\w+)="?(.+?)"?$/)
        end.to_h
      rescue Errno::ENOENT
        {}
      end
    end

    def self.current_os_names
      # ID=ubuntu
      # ID_LIKE=debian
      os_release.values_at("ID", "ID_LIKE").compact
    end

    def self.nice_os_name
      os_release.values_at("PRETTY_NAME", "NAME", "ID", "ID_LIKE").first || 
        (`uname -o`.chomp rescue nil)
    end

    def self.for_os(os_names=nil)
      os_names = os_names ? [os_names].flatten : current_os_names

      tool = nil

      if os_names.any?
        tool = @@tools.find { |name, tool| os_names.any? { |name| tool.os.include? name } }.last
      end

      if tool.nil?
        tool = @@tools.find { |name, tool| File.which(tool.identifying_binary) }.last
      end

      if tool.nil?
        puts "Error: couldn't find a package manager."
      end
    end

    ###################################################################

    def initialize(name, &block)
      @name = name
      instance_eval(&block)

      @@tools[name] = self
    end

    def call_command(name, *args)
      if block = (@cmds[name] || @cmds[ALIASES[name]])
        block.call args
      else
        puts "Command #{name} not supported in #{@name}"
      end
    end

    def help
      if osname = Tool.nice_os_name
        puts "    Detected OS: #{osname}"
      end

      puts "Package manager: #{@name}"
      puts
      puts "Available commands:"
      available = COMMAND_HELP.select do |name, desc|
        names = name.split("/")
        names.any? { |name| @cmds[name] }
      end

      max_width = available.map(&:first).map(&:size).max
      available.each do |name, desc|
        puts "  #{name.rjust(max_width)} | #{desc}"
      end
    end

    ## DSL methods

    def identifying_binary(id_bin=nil)
      if id_bin 
        @id_bin = id_bin
      else
        @id_bin || @name
      end
    end

    def prefix(name)
      @prefix = name
    end

    def command(name, shell_command=nil, root: false, paged: false, &block)
      @cmds ||= {}

      if block_given?
        @cmds[name] = block
      elsif shell_command
        if shell_command.is_a? String
          shell_command = shell_command.split
        elsif not shell_command.is_a? Array
          raise "Error: command argument must be a String or an Array; it was a #{cmd.class}"
        end

        @cmds[name] = proc { |args| run(*shell_command, *args, paged: paged) }
      end
    end

    def os(*names)
      names.any? ? @os = names : @os
    end

    ## Helpers

    def run(*args, root: false, paged: false, grep: nil)
      args.unshift "sudo" if root

      if !paged and !grep
        system(*args)
      else

        IO.popen(args, err: [:child, :out]) do |command_io|
          
          if grep
            pattern = grep.is_a?(Regexp) ? grep.source : grep.to_s 
            grep_io = IO.popen(["grep", "--color=always", "-Ei", pattern], "w+")
            IO.copy_stream(command_io, grep_io)
            grep_io.close_write
            command_io = grep_io
          end

          if paged
            lesspipe do |less|
              IO.copy_stream(command_io, less)
            end
          else
            IO.copy_stream(command_io, STDOUT)
          end

        end

        $?.to_i == 0
      end
    end

    def print_files(*paths, include: nil, exclude: nil)
      lesspipe do |less|
        paths.each do |path|
          less.puts "<8>=== <11>#{path} <8>========".colorize
          open(path) do |io|
            enum = io.each_line
            enum = enum.grep(include) if include
            enum = enum.reject { |line| line[exclude] } if exclude
            enum.each { |line| less.puts line }
          end
          less.puts
        end
      end
    end

  end # class Tool

end # module UPM

