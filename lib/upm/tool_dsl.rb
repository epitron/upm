require 'pathname'
require 'fileutils'

module UPM
  class Tool
    module DSL
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

      def os(*args)
        args.any? ? @os = args : @os
      end

      def max_database_age(age)
        @max_database_age = age.to_i
      end

      def cache_dir(dir)
        @cache_dir = Pathname.new(dir).expand_path
        @cache_dir.mkpath unless @cache_dir.exist?
      end

      def config_dir(dir)
        @config_dir = Pathname.new(dir).expand_path
        @config_dir.mkpath unless @config_dir.exist?
      end

      def set_default(key, value)
        send(key, value)
      end

      def command(name, shell_command=nil, root: false, paged: false, highlight: nil, &block)
        @cmds ||= {}

        if block_given?

          if root and Process.uid != 0
            @cmds[name] = proc { exec("sudo", $PROGRAM_NAME, *ARGV) }
          else
            @cmds[name] = block
          end

        elsif shell_command

          if shell_command.is_a? String
            shell_command = shell_command.split
          elsif not shell_command.is_a? Array
            raise "Error: command argument must be a String or an Array; it was a #{cmd.class}"
          end

          @cmds[name] = proc do |args|
            query = highlight ? args.join("\\s+") : nil
            run(*shell_command, *args, paged: paged, root: root, highlight: query)
          end

        else
          raise "Error: Must supply a block or shell command"
        end
      end

      ## Helpers

      def run(*args, root: false, paged: false, grep: nil, highlight: nil, sort: false)
        if root
          if Process.uid != 0
            if File.which("sudo")
              args.unshift "sudo"
            elsif File.which("su")
              args = ["su", "-c"] + args
            else
              raise "Error: You must be root to run this command. (And I couldn't find the 'sudo' *or* 'su' commands.)"
            end
          end
        end


        unless paged or grep or sort
          system(*args)
        else
          IO.popen(args, err: [:child, :out]) do |command_io|

            # if grep
            #   pattern = grep.is_a?(Regexp) ? grep.source : grep.to_s
            #   grep_io = IO.popen(["grep", "--color=always", "-Ei", pattern], "w+")
            #   IO.copy_stream(command_io, grep_io)
            #   grep_io.close_write
            #   command_io = grep_io
            # end

            # if paged
            #   lesspipe do |less|
            #     IO.copy_stream(command_io, less)
            #   end
            # else
            #   IO.copy_stream(command_io, STDOUT)
            # end

            # highlight_proc = if highlight
            #   proc { |line| line.gsub(highlight) { |m| "\e[33;1m#{m}\e[0m" } }
            # else
            #   proc { |line| line }
            # end

            lesspipe(disabled: !paged, search: highlight, always: false) do |less|
              each_proc = if grep
                proc { |line| less.puts line if line[grep] }
              else
                proc { |line| less.puts line }
              end

              lines = command_io.each_line
              lines = lines.to_a.sort if sort
              lines.each(&each_proc)
            end

          end

          $?.to_i == 0
        end
      end

      def curl(url)
        IO.popen(["curl", "-Ss", url], &:read)
      rescue Errno::ENOENT
        puts "Error: 'curl' isn't installed. You need this!"
        exit 1
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

      def call_command(name, *args)
        if block = (@cmds[name] || @cmds[ALIASES[name]])
          block.call args
        else
          puts "Command #{name.inspect} not supported by #{@name.inspect}"
        end
      end

      def database_lastupdate_file
        raise "Error: Tool 'name' is not set" unless @name
        raise "Error: 'cache_dir' is not set" unless @cache_dir
        @cache_dir/"#{@name}-last-update"
      end

      def database_updated!
        FileUtils.touch(database_lastupdate_file)
      end

      def database_lastupdate
        database_lastupdate_file.exist? ? File.mtime(database_lastupdate_file) : 0
      end

      def database_age
        Time.now.to_i - database_lastupdate.to_i
      end

      def database_needs_updating?
        database_age > @max_database_age
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

    end # DSL
  end # Tool
end # UPM
