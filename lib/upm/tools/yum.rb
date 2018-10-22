UPM::Tool.new "yum" do

  os "centos", "fedora", "rhel"

  command "install", "yum install",  root: true
  command "remove",  "yum remove",   root: true
  command "update",  "yum update",   root: true
  command "upgrade", "yum upgrade",  root: true
  command "clean",   "yum clean",    root: true

  command "files",   "rpm -ql",  paged: true
  command "search" do |args|
    query = args.join(".+")
    run "yum", "search", *args, sort: true, paged: true, highlight: query
  end

  command "list" do |args|
    if args.any?
      highlight_query = args.join(".+")
      grep_query = /#{highlight_query}/
      run "yum", "list", "installed", grep: grep_query, highlight: highlight_query, paged: true
    else
      run "yum", "list", "installed", paged: true
    end
  end

end
