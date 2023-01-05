UPM::Tool.new "pkgman" do

  os "Haiku"

  def installed_packages
    Pathname.new("/packages").each_child.map { |dir| dir.basename.to_s }
  end

  def hpkg_dir
    Pathname.new("/system/packages")
  end

  def hpkg_file(name)
    r = hpkg_dir.glob("#{name}-*.hpkg").sort
    # p r
    r.last
  end

  command "install",  "pkgman install",   root: true
  command "remove",   "pkgman uninstall", root: true
  command "upgrade",  "pkgman update",   root: true
  command "repos",    "pkgman list-repos", paged: true

  #command "search", "pkgman search", paged: true, highlight: true

  command "search" do |args|
    #query = args.join(".*")
    #p query: query
    run "pkgman", "search", args.join(" "), highlight: "(#{ args.join("|") })", paged: true
  end

  command "info" do |args|
    args.each { |arg| run("package", "list", "-i", hpkg_file(arg).to_s, paged: true) }
  end

  command "files" do |args|
    args.each { |arg| run("package", "list", "-p", hpkg_file(arg).to_s, paged: true) }
  end

  command "list" do |args|
    lesspipe(search: "(#{args.join("|")})") do |less|
      installed_packages.sort.each do |pkg|
        less.puts pkg
      end
    end
  end
    

  #command "clean",    "",    root: true
  #command "verify",   ""

end
