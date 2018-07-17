UPM::Tool.new "opkg" do

  os "openwrt", "lede"

  command "install", "opkg install",      root: true
  command "update",  "opkg update",       root: true
  command "upgrade", root: true do |args|
    pkgs = `opkg list-upgradable`.each_line.map { |line| line.split.first }
    run "opkg", "upgrade", *pkgs
  end

  command "search" do |args|
    query = args.join
    run "opkg", "list", grep: query, paged: true
  end

  command "list" do |args|
    if args.any?
      query = args.join
      run "opkg", "list-installed", grep: query, paged: true
    else
      run "opkg", "list-installed", paged: true
    end
  end

end
