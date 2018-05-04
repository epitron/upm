module UPM
  class LogParser

    def initialize(klass, log_glob)
      @klass = klass
      @log_glob = log_glob
    end

    def log_events
      return to_enum(:log_events) unless block_given?

      yielder = proc do |io|
        io.each_line do |line|
          if e = @klass.from_line(line.strip)
            yield e
          end
        end
      end

      logs = Dir[@log_glob].sort_by { |path| File.mtime(path) } 

      logs.each do |log|
        if log =~ /\.gz$/
          IO.popen(["zcat", log], &yielder)
        else
          open(log, &yielder)
        end 
      end
    end

    def display
      lesspipe(tail: true) do |less|
        groups = log_events.split_between { |a,b| (b.date.to_i - a.date.to_i) > 60 }

        groups.each do |group|
          first, last = group.first.date, group.last.date
          elapsed     = (last.to_i - first.to_i) / 60

          empty_group = true

          group.each do |ev|
            # Print the header only if the query matched something in this group
            if empty_group
              empty_group = false
              less.puts
              less.puts "<8>== <11>#{first.strftime("<10>%Y-%m-%d <7>at <2>%l:%M %p")} <7>(<9>#{elapsed} <7>minute session) <8>========".colorize
            end

            less.puts ev
          end
        end
      end # lesspipe
    end

  end # LogParser
end