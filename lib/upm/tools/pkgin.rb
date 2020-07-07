#
# Command reference:
#   https://pkgin.net/#examples
#
# NB: add -y after command to skip y/n prompt
#
UPM::Tool.new "pkgin" do

  os "MINIX", "NetBSD", "SunOS"

  command "install", "pkgin install", root: true
  command "update",  "pkgin update",  root: true
  command "upgrade", "pkgin upgrade", root: true
  command "clean",   "pkgin clean",   root: true

  command "which",   "pkg_info -Fe"
  command "info",    "pkg_info",           paged: true
  command "files",   "pkg_info -qL",       paged: true
  command "list",    "pkgin list",         paged: true
  command "search",  "pkgin search",       paged: true, highlight: true
  command "log",     "grep pkg: /var/log/messages", paged: true
  command "stats",   "pkgin stats"
  # command "verify"

  command "mirrors" do
    print_files("/opt/local/etc/pkgin/repositories.conf", exclude: /^(#|$)/)
  end

  command "group" do |args|
    if args.any?
      run "pkgin", "show-category", *args
    else
      run "pkgin", "show-all-categories"
    end
  end

  command "audit" do |args|
    run "pkg_admin", "fetch-pkg-vulnerabilities"

    if args.any?
      run "pkg_admin", "audit-pkg", *args, paged: true
    else
      run "pkg_admin", "audit", paged: true
    end
  end

  command "keep" do |args|
    if args.any?
      run "pkgin", "keep", *args, root: true
    else
      run "pkgin", "show-keep", root: true
    end
  end

  command "unkeep" do |args|
    if args.any?
      run "pkgin", "unkeep", *args, root: true
    else
      run "pkgin", "show-no-keep", root: true
    end
  end

end
