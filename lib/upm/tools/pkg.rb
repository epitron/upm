require 'upm/freshports_search'

UPM::Tool.new "pkg" do

  os "FreeBSD"

  command "install", "pkg install", root: true
  command "update",  "pkg update",  root: true
  command "upgrade", "pkg upgrade", root: true
  command "audit",   "pkg audit",   root: true
  command "verify",  "pkg check --checksums", root: true

  command "files",   "pkg list",    paged: true
  command "search",  "pkg search",  paged: true, highlight: true
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

  # pkg clean # cleans /var/cache/pkg/
  # rm -rf /var/cache/pkg/* # just remove it all
  # pkg update -f # forces update  of repository catalog
  # rm /var/db/pkg/repo-*.sqlite # removes all remote repository catalogs
  # pkg bootstrap -f # forces reinstall of pkg
  command "clean",   "pkg clean",   root: true

end
