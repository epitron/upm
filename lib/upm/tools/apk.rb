UPM::Tool.new "apk" do

  os "alpine"

  command "install", "apk add",      root: true
  command "remove",  "apk del",      root: true
  command "update",  "apk update",   root: true
  command "upgrade", "apk upgrade",  root: true
  command "clean",   "apk clean",    root: true

  command "files",   "apk info -L",  paged: true
  command "search" do |args|
    query = args.join(".+")
    run "apk", "search", *args, sort: true, paged: true, highlight: query
  end

  command "list" do |args|
    if args.any?
      highlight_query = args.join(".+")
      grep_query = /#{highlight_query}/
      run "apk", "info", grep: grep_query, highlight: highlight_query, paged: true
    else
      run "apk", "info", paged: true
    end
  end

end
