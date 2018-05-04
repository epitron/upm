UPM::Tool.new "pacman" do

  os "arch"

  command "install",  "pacman -S", root: true
  command "update",   "pacman -Sy", root: true
  command "upgrade",  "pacman -Syu", root: true

  command "files",  "pacman -Ql"
  command "search", "pacman -Ss"
  command "info" do |args|
    run("pacman", "-Qi", *args) || run("pacman", "-Si", *args)
  end

  command "list" do |args|
    opt = args.any? ? "-Ql" : "-Q"
    run("pacman", opt, *args)
  end

  command "depends" do |args|
    args.each do |arg|
      puts "=== Packages which depend on: #{arg} ============"
      packages = packages_that_depend_on(arg)
      puts
      run "pacman", "-Ss", "^(#{packages.join '|'})$" # upstream packages
      run "pacman", "-Qs", "^(#{packages.join '|'})$" # packages that are only installed locally
      puts
    end
  end

  def packages_that_depend_on(package)
    result = []

    [`pacman -Sii #{package}`, `pacman -Qi #{package}`].each do |output|
      output.each_line do |l|
        if l =~ /Required By\s+: (.+)/
          result += $1.strip.split unless $1["None"]
          break
        end
      end
    end

    result
  end

end
