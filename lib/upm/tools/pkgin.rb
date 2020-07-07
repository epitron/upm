UPM::Tool.new "pkgin" do

  os "MINIX", "NetBSD", "SunOS"

  command "install", "pkgin install", root: true
  command "update",  "pkgin update",  root: true
  command "upgrade", "pkgin upgrade", root: true
  command "info",    "pkgin clean",   root: true
  command "audit",   "pkg_admin fetch-pkg-vulnerabilities && pkg_admin audit", root: true, paged: true
  command "verify",  "pkgin check --checksums", root: true

  command "list",    "pkgin list", paged: true
  command "info",    "pkg_info",    paged: true
  command "files",   "pkgin pkg-content",  paged: true
  command "search",  "pkgin search",  paged: true, highlight: true
  command "log",     "grep pkg: /var/log/messages", paged: true
  command "stats",   "pkgin stats"
  command "pinned",  "pkgin show-keep"

  command "mirrors" do
    print_files("/opt/local/etc/pkgin/repositories.conf", exclude: /^(#|$)/)
  end

/opt/local/pkg/pkg-vulnerabilities


  command "group" do |*args|
    if args.any?
      run "pkgin", "show-category", *args
    else
      run "pkgin", "show-all-categories"
    end
  end

end
