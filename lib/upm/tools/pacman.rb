UPM::Tool.new "pacman" do

  os "arch"

  bin = ["pacman", "--color=always"]

  command "install", [*bin, "-S"],   root: true
  command "update",  [*bin, "-Sy"],  root: true
  command "upgrade", [*bin, "-Syu", "--noconfirm"], root: true
  command "remove",  [*bin, "-R"],   root: true

  command "verify", root: true do |args|
    require 'upm/pacman_verifier'
    UPM::PacmanVerifier.new.verify!(*args)
  end

  command "audit",  "arch-audit",  paged: true
  command "files",  [*bin, "-Ql"], paged: true
  command "search", [*bin, "-Ss"], paged: true, highlight: true

  command "info" do |args|
    run(*bin, "-Qi", *args, paged: true) || run(*bin, "-Si", *args, paged: true)
  end

  command "list" do |args|
    if args.any?
      query = args.join
      run(*bin, "-Q", grep: query, highlight: query, paged: true)
    else
      run(*bin, "-Q", paged: true)
    end
  end

  command "mirrors" do
    print_files("/etc/pacman.d/mirrorlist", exclude: /^(#|$)/)
    print_files("/etc/pacman.conf", include: /^Server\s*=/, exclude: /^(#|$)/)
  end

  command "depends" do |args|
    packages_that_depend_on = proc do |package|
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

    args.each do |arg|
      puts "=== Packages which depend on: #{arg} ============"
      packages = packages_that_depend_on.call(arg)
      puts
      run *bin, "-Ss", "^(#{packages.join '|'})$" # upstream packages
      run *bin, "-Qs", "^(#{packages.join '|'})$" # packages that are only installed locally
      puts
    end
  end

  command "log" do
    UPM::LogParser.new(PacmanEvent, "/var/log/pacman.log*").display
  end

  class PacmanEvent < Struct.new(:datestr, :date, :cmd, :name, :v1, :v2)

    # [2015-01-04 04:21] [PACMAN] installed lib32-libidn (1.29-1)
    # [2015-01-04 04:21] [PACMAN] upgraded lib32-curl (7.38.0-1 -> 7.39.0-1)
    # [2015-01-07 04:39] [ALPM] upgraded intel-tbb (4.3_20141023-1 -> 4.3_20141204-1)
    # [2015-01-07 04:39] [ALPM] upgraded iso-codes (3.54-1 -> 3.57-1)

    DATE_RE = /[\d:-]+/
    LINE_RE = /^\[(#{DATE_RE} #{DATE_RE})\](?: \[(?:PACMAN|ALPM)\])? (removed|installed|upgraded) (.+) \((.+)(?: -> (.+))?\)$/

    CMD_COLORS = {
      'removed' => :light_red,
      'installed' => :light_yellow,
      'upgraded' => :light_green,
      nil => :white,
    }

    def self.parse_date(date)
      DateTime.strptime(date, "%Y-%m-%d %H:%M")
    end

    def self.from_line(line)
      if line =~ LINE_RE
        new($1, parse_date($1), $2, $3, $4, $5)
      else
        nil
      end
    end

    def cmd_color
      CMD_COLORS[cmd]
    end

    def to_s
      date, time = datestr.split
      "<grey>[<white>#{date} #{time}<grey>] <#{cmd_color}>#{cmd} <light_cyan>#{name} #{"<light_white>#{v2} " if v2}<white>(#{v1})".colorize
    end

  end

end
