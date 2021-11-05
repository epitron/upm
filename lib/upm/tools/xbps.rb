UPM::Tool.new "xbps" do

  os "void"

  identifying_binary "xbps-install"

  command "install", "xbps-install",      root: true
  command "update",  "xbps-install -S",   root: true
  command "upgrade", "xbps-install -Su",  root: true
  command "files",   "xbps-query -f",           paged: true
  command "selection", "xbps-query -m"

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

end
