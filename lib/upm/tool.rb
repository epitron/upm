
# os:<pkg> -- automatically select the package manager for the current unix distribution
# deb:<pkg> (or d: u:)
# rpm:<pkg> (or yum: y:)
# bsd:<pkg> (or b:)
# ruby:<pkg> (or r: gem:)
# python:<pkg>,<pkg> (or py: p: pip:)

module UPM

  class Tool

    @@tools = {}

    def self.register_tools!
      Dir["#{__dir__}/tools/*.rb"].each { |lib| require_relative(lib) }
    end

    def self.current_os_names
      open("/etc/os-release") do |io|
        # ID=ubuntu
        # ID_LIKE=debian
        io.grep(/^ID(?:_LIKE)?=(.+)/) { $1 }
      end
    end

    def self.for_os(os_names=nil)
      os_names = os_names ? [os_names].flatten : current_os_names
      @@tools.find { |name, tool| os_names.any? { |name| tool.os.include? name } }.last
    end

    def self.tools
      @@tools
    end

    
    # Commands:
    # ------------------
    # install
    # remove
    # build - compile a package from source and install it
    # search - using the fastest known API or service
    # list - show all packages, or the contents of a specific package
    # info - show metadata about a package
    # sync/update - retrieve the latest package list or manifest
    # upgrade - install new versions of all packages
    # pin - pinning a package means it won't be automatically upgraded
    # rollback - revert to an earlier version of a package (including its dependencies)
    # log - show history of package installs
    # packagers - detect installed package managers, and pick which ones upm should wrap
    # sources/mirrors - select remote repositories and mirrors
    # verfiy - verifies the integrity of installed files
    # clean - clear out the local package cache
    # monitor - ad-hoc package manager for custom installations (like instmon)
    # keys - keyrings and package authentication
    # default - configure the action to take when no arguments are passed to "upm" (defaults to "os:update")
    
    ALIASES = {
      "sync"    => "update",
      "sources" => "mirrors",
    }

    def initialize(name, &block)
      @name = name
      instance_eval(&block)

      @@tools[name] = self
    end

    ## DSL methods

    def prefix(name)
      @prefix = name
    end

    def command(name, shell_command=nil, root: false, &block)
      @cmds ||= {}

      if block_given?
        @cmds[name] = block
      elsif shell_command
        
        if shell_command.is_a? String
          shell_command = shell_command.split
        elsif not shell_command.is_a? Array
          raise "Error: command argument must be a String or an Array; it was a #{cmd.class}"
        end

        shell_command.unshift "sudo" if root

        @cmds[name] = proc { |args| system(*shell_command, *args) }
      end
    end

    def os(*names)
      names.any? ? @os = names : @os
    end

    ## Helpers

    def run(*args)
      system(*args)
    end

    def call_command(name, args)
      if block = @cmds[name]
        block.call args
      else
        puts "Command #{name} not supported in #{@name}"
      end
    end

    def help
      puts "#{@name} supported commands:"
      puts "   #{@cmds.keys.join(", ")}"
    end

  end
end

