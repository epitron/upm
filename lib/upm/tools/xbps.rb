UPM::Tool.new "xbps" do

  os "void"

  identifying_binary "xbps-install"

  command "install",   "xbps-install",      root: true
  command "remove",    "xbps-remove",       root: true
  command "update",    "xbps-install -S",   root: true
  command "upgrade",   "xbps-install -Su",  root: true
  command "files",     "xbps-query -f",     paged: true
  command "locate",    "xlocate",           paged: true
  command "selection", "xbps-query -m",     paged: true
  command "rdeps",     "xbps-query -X",     paged: true

  command "info" do |args|
    args.each do |arg|
      unless run("xbps-query", "-S", arg)
        run("xbps-query", "-R", "-S", arg)
      end
      puts
    end
  end

  command "search" do |args|
     query = args.join(".*")
     run "xbps-query", "--regex", "-Rs", query, highlight: /(#{ args.join("|") })/i, paged: true
  end
  
  command "list" do |args|
    if args.any?
      query = args.join
      run "xbps-query", "-l", grep: query, paged: true
    else
      run "xbps-query", "-l", paged: true
    end
  end



  class XBPSPackage < Struct.new(:name, :version, :date)
    def self.from_line(line)
      # zd1211-firmware-1.5_3: 2021-09-01 15:22 UTC
      if line =~ /^([\w\-]+)-([\d\.]+_\d+): (.+)$/
        name, version, date = $1, $2, $3
        date = DateTime.parse($3)
        new(name, version, date)
      else
        nil
      end
    end

    def to_s
      "[#{date.strftime("%Y-%m-%d %H:%M:%S")}] #{name} #{version}"
    end
  end

  command "log" do |args|
    fakedata = %{
	xset-1.2.4_1: 2021-11-05 15:03 UTC
	xsetroot-1.1.2_1: 2021-11-05 15:03 UTC
	xtools-0.63_1: 2021-11-05 16:36 UTC
	xtrans-1.4.0_2: 2021-11-05 15:26 UTC
	xvidcore-1.3.7_1: 2021-11-05 16:45 UTC
	xvinfo-1.1.4_2: 2021-11-05 15:03 UTC
	xwd-1.0.8_1: 2021-11-05 15:03 UTC
	xwininfo-1.1.5_1: 2021-11-05 15:03 UTC
	xwud-1.0.5_1: 2021-11-05 15:03 UTC
	xz-5.2.5_2: 2021-11-05 15:12 UTC
	zd1211-firmware-1.5_3: 2021-09-01 15:22 UTC
	zip-3.0_6: 2021-11-05 17:45 UTC
	zlib-1.2.11_4: 2021-09-01 14:14 UTC
	zlib-devel-1.2.11_4: 2021-11-05 15:26 UTC
    }

    data = IO.popen(["xbps-query", "-p", "install-date", "-s", ""], &:read)
    packages = data.each_line.map do |line|
      XBPSPackage.from_line(line.strip)
    end.compact
    packages.sort_by!(&:date)
    packages.each { |pkg| puts pkg }
  end
end
    
