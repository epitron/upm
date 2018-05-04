UPM::Tool.new "apt" do

  os "debian", "ubuntu"

  command "install",  "apt install", root: true
  command "update",   "apt update",  root: true
  command "upgrade",  "apt upgrade", root: true

  command "files",  "dpkg -L"
  command "search", "apt search"
  command "info", "apt show"
  command "list" do |args|
    if args.any?
      run("dpkg", "-l", *args)
    else
      run("apt", "list")
    end
  end

  command "log" do
    UPM::LogParser.new(DpkgEvent).display
  end

  class DpkgEvent < Struct.new(:datestr, :date, :cmd, :name, :v1, :v2)

    # 2010-12-03 01:36:56 remove gir1.0-mutter-2.31 2.31.5-0ubuntu9 2.31.5-0ubuntu9
    # 2010-12-03 01:36:58 install gir1.0-mutter-2.91 <none> 2.91.2+git20101114.982a10ac-0ubuntu1~11.04~ricotz0  
    #LINE_RE = /^(.+ .+) (status \w+|\w+) (.+) (.+)$/
    LINE_RE = /^(.+ .+) (remove|install|upgrade) (.+) (.+) (.+)$/

    CMD_COLORS = {
      'remove' => :light_red,
      'install' => :light_yellow,
      'upgrade' => :light_green,
      nil => :white,
    }
    
    def self.parse_date(date)
      DateTime.strptime(date, "%Y-%m-%d %H:%M:%S")
    end
   
    def self.from_line(line)
      if line =~ LINE_RE
        new($1, parse_date($1), $2, $3, $4, $5)
      else
        nil
      end
    end    
    
    def cmd_color
      CMD_COLORS[cmd]
    end

    def to_s
      date, time = datestr.split
      "<grey>[<white>#{date} #{time}<grey>] <#{cmd_color}>#{cmd} <light_cyan>#{name} <light_white>#{v2} <white>(#{v1})".colorize
    end  

  end
      
end
