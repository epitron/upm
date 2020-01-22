require 'upm/freshports_search'

UPM::Tool.new "pkg" do

  os "FreeBSD"

  command "install", "pkg install", root: true
  command "update",  "pkg update",  root: true
  command "upgrade", "pkg upgrade", root: true
  command "remove",  "pkg remove", root: true
  command "info",    "pkg clean",   root: true
  command "audit",   "pkg audit",   root: true
  command "verify",  "pkg check --checksums", root: true
  command "which",   "pkg which"

  # command "files",   "pkg list",    paged: true
  command "files" do |args|
    if args.empty?
      run "pkg", "info", "--list-files", "--all", paged: true
    else
      run "pkg", "list", *args, paged: true
    end
  end

  # the "pkg-provides" plugin is similar to arch's "pkgfile" (requires updates), and needs to be added to the plugins section of pkg's config ("pkg plugins" shows loaded plugins)
  command "provides" do |args|
    run "pkg", "info", "--list-files", "--all", grep: /#{args.join(".+")}/, highlight: true
  end

  command "search",  "pkg search",  paged: true, highlight: true
  command "search-sources" do |*args|
    query = args.join(" ")
    FreshportsSearch.new.search!(query)
  end

  # command "log", "grep -E 'pkg.+installed' /var/log/messages", paged: true
  command "log" do
    lesspipe do |less|
      open("/var/log/messages").each_line do |line|
        # Jan 19 18:25:21 freebsd pkg[815]: pcre-8.43_2 installed
        if line =~ /^(\S+ \S+ \S+) (\S+) pkg(?:\[\d+\])?: (\S+)-(\S+) installed/
          timestamp = DateTime.parse($1)
          host = $2
          pkgname = $3
          pkgver = $4
          less.puts "#{timestamp} | #{pkgname} #{pkgver}"
        end
      end
    end
  end

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
