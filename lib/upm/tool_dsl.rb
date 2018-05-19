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

      def command(name, shell_command=nil, root: false, paged: false, highlight: nil, &block)
        @cmds ||= {}

        if block_given?
          @cmds[name] = block
        elsif shell_command
          if shell_command.is_a? String
            shell_command = shell_command.split
          elsif not shell_command.is_a? Array
            raise "Error: command argument must be a String or an Array; it was a #{cmd.class}"
          end

          @cmds[name] = proc do |args|
            query = highlight && args.join(" ") 
            run(*shell_command, *args, paged: paged, root: root, highlight: query)
          end
        end
      end

      def os(*names)
        names.any? ? @os = names : @os
      end

      ## Helpers

      def run(*args, root: false, paged: false, grep: nil, highlight: nil)
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

        if !paged and !grep
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

            highlight_proc = if highlight
              proc { |line| line.gsub(highlight) { |m| "\e[33;1m#{m}\e[0m" } }
            else
              proc { |line| line }
            end

            grep_proc = if grep
              proc { |line| line[grep] }
            else
              proc { true }
            end

            lesspipe(disabled: !paged) do |less|
              command_io.each_line do |line|
                less.puts highlight_proc.(line) if grep_proc.(line)
              end
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

      def call_command(name, *args)
        if block = (@cmds[name] || @cmds[ALIASES[name]])
          block.call args
        else
          puts "Command #{name.inspect} not supported by #{@name.inspect}"
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

    end # DSL
  end # Tool
end # UPM
