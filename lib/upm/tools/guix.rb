class GUIXPackage < Struct.new(:name, :version, :out, :path)
  def self.from_line(line)
    new(*line.chomp.split)
  end

  def self.installed
    @installed_packages ||= IO.popen(["guix", "package", "--list-installed"]) { |io| io.each_line.map { |line| GUIXPackage.from_line(line) } }
  end

  def self.avaialble
    @available_packages ||= IO.popen(["guix", "package", "--list-available"]) { |io| io.each_line.map { |line| GUIXPackage.from_line(line) } }
  end

  def installed?
    !!path[%r{^/gnu/store/}]
  end
end


UPM::Tool.new "guix" do

  identifying_binary "guix"

  command "install",    "guix install"
  command "remove",     "guix remove"
  command "info",       "guix show"
  command "rollback",   "guix package –roll-back"
  command "selfupdate", "guix pull"
  command "upgrade",    "guix package --upgrade"

  command "files", paged: true do |args|
    error "Ope, you forgot the package name!" if args.empty?

    args.each do |arg|
      if pkg = GUIXPackage.installed.find { |pkg| pkg.name == arg }
        run "find", pkg.path, paged: true
      else
        error "#{arg.inspect} not found"
      end
    end
  end

  command "search" do |args|
    query           = args.join(" ")
    highlight_query = args.join(".+")
    grep_query      = args.join(".+")
    run "guix", "package", "--list-available", sort: true, grep: grep_query, paged: true, highlight: highlight_query
  end

  command "list" do |args|
    if args.any?
      highlight_query = args.join(".+")
      grep_query = /#{highlight_query}/
      run "guix", "package", "--list-installed", grep: grep_query, highlight: highlight_query, paged: true
    else
      run "guix", "package", "--list-installed", paged: true
    end
  end

end
