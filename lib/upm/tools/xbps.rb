UPM::Tool.new "xbps" do

  os "void"

  identifying_binary "xbps-install"

  command "install", "xbps-install", root: true
  command "update",  "xbps-install -S", root: true
  command "upgrade", "xbps-install -Su", root: true
  command "files",   "xbps-query -f"
  command "search",  "xbps-query --regex -Rs"
  # command "info", ""
  
  command "list" do |args|
    if args.any?
      run "xbps-query", "-f", *args
    else
      run "xbps-query", "-l"
    end
  end

end
