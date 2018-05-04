UPM::Tool.new "apt" do

  os "debian", "ubuntu"

  command "install",  "apt install", root: true
  command "update",   "apt update",  root: true
  command "upgrade",  "apt upgrade", root: true

  command "files",  "dpkg -L"
  command "search", "apt search"
  command "info", "apt show"
  command "list" do |args|
    if args.any?
      run("dpkg", "-l", *args)
    else
      run("apt", "list")
    end
  end

end
