UPM::Tool.new "pkg_add" do

  os "OpenBSD"

  command "install",  "pkg_add",      root: true
  command "remove",   "pkg_delete",   root: true
  command "upgrade",  "pkg_add -u",   root: true
  command "clean",    "yum clean",    root: true
  command "info",     "pkg_info",     paged: true
  command "files",    "pkg_info -L",  paged: true
  command "search",   "pkg_info -Q",  paged: true
  command "verify",   "pkg_check"

  command "list" do |args|
    if args.any?
      highlight_query = args.join(".+")
      grep_query = /#{highlight_query}/
      run "pkg_info", grep: grep_query, highlight: highlight_query, paged: true
    else
      run "pkg_info", paged: true
    end
  end

end
