UPM::Tool.new "pkgin" do

  os "MINIX", "NetBSD"

  command "install", "pkgin install", root: true
  command "update",  "pkgin update",  root: true
  command "upgrade", "pkgin upgrade", root: true
  command "info",    "pkgin clean",   root: true
  command "audit",   "pkgin audit",   root: true
  command "verify",  "pkgin check --checksums", root: true

  command "files",   "pkgin list",    paged: true
  command "search",  "pkgin search",  paged: true, highlight: true
  command "search-sources" do |*args|
    query = args.join(" ")
    FreshportsSearch.new.search!(query)
  end

  command "log", "grep pkg: /var/log/messages", paged: true

  command "build" do |*args|
    # svn checkout --depth empty svn://svn.freebsd.org/ports/head /usr/ports
    # cd /usr/ports
    # svn update --set-depth files
    # svn update Mk
    # svn update Templates
    # svn update Tools
    # svn update --set-depth files $category
    # cd $category
    # svn update $port
    puts "Not implemented"
  end

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
