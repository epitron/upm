UPM::Tool.new "pkg" do

  os "FreeBSD"

  command "update", root: true do
    if database_needs_updating?
      run "pkg", "update" 
      database_updated!
    else
      puts "Database has already been updated recently. Skipping."
    end
  end

  command "install", root: true do |args|
    call_command "update"
    run "pkg", "install", "--no-repo-update", *args
  end

  command "upgrade", root: true do
    call_command "update"
    run "pkg", "upgrade", "--no-repo-update"
  end

  command "remove",  "pkg remove",  root: true
  command "audit",   "pkg audit",   root: true
  command "clean",   "pkg clean -a",root: true
  command "verify",  "pkg check --checksums", root: true
  command "which",   "pkg which"

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
    require 'upm/freshports_search'
    query = args.join(" ")
    FreshportsSearch.new.search!(query)
  end

  # command "log", "grep -E 'pkg.+installed' /var/log/messages", paged: true
  command "log" do
    require 'upm/core_ext/file'
    lesspipe do |less|
      open("/var/log/messages").reverse_each_line do |line|
        # Jan 19 18:25:21 freebsd pkg[815]: pcre-8.43_2 installed
        # Apr  1 16:55:58 freebsd pkg[73957]: irssi-1.2.2,1 installed
        if line =~ /^(\S+\s+\S+\s+\S+) (\S+) pkg(?:\[\d+\])?: (\S+)-(\S+) installed/
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

  # pkg clean # cleans /var/cache/pkg/
  # rm -rf /var/cache/pkg/* # just remove it all
  # pkg update -f # forces update  of repository catalog
  # rm /var/db/pkg/repo-*.sqlite # removes all remote repository catalogs
  # pkg bootstrap -f # forces reinstall of pkg

end
