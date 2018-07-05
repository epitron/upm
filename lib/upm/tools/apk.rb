UPM::Tool.new "apk" do

  os "alpine"

  command "install", "apk add",      root: true
  command "update",  "apk update",   root: true
  command "upgrade", "apk upgrade",  root: true

  command "files",   "apk info -L", paged: true
  command "search",  "apk search",  paged: true

  command "clean",   "apk clean"
  
  command "list" do |args|
    if args.any?
      query = args.join
      run "apk", "info", grep: query, paged: true
    else
      run "apk", "info", paged: true
    end
  end

end
