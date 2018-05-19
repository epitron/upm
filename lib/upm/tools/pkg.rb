UPM::Tool.new "pkg" do

  os "FreeBSD"

  command "install", "pkg install", root: true
  command "update",  "pkg update",  root: true
  command "upgrade", "pkg upgrade", root: true
  command "info",    "pkg clean",   root: true
  command "audit",   "pkg audit",   root: true
  command "verify",  "pkg check --checksums", root: true

  command "files",   "pkg list",    paged: true
  command "search",  "pkg search",  paged: true, highlight: true
  command "info",    "pkg info",    paged: true

  command "list" do |args|
    if args.any?
      query = args.join
      run "pkg", "info", grep: query, highlight: query, paged: true
    else
      run "pkg", "info", paged: true
    end
  end

  command "mirrors" do
    print_files("/etc/pkg/FreeBSD.conf", exclude: /^(#|$)/)
  end

end
