require 'zlib'
require 'digest/sha2'
require 'digest/md5'
require 'pp'

module UPM
  class PacmanVerifier

    SKIP_FILES = %w[
      /.BUILDINFO
      /.INSTALL
      /.PKGINFO 
      /.CHANGELOG
    ]

    PACKAGE_ROOT = "/var/lib/pacman/local/"

    def compare(key, a, b)
      a == b ? nil : [key, a, b]
    end

    def verify!(*included)
      $stderr.puts "Checking integrity of #{included.any? ? included.size : "installed"} packages..."

      report = []

      Dir.entries(PACKAGE_ROOT).each do |package_dir|
        mtree_path = File.join(PACKAGE_ROOT, package_dir, "mtree")
        next unless File.exists?(mtree_path)

        chunks = package_dir.split("-")
        version = chunks[-2..-1].join("-")
        package = chunks[0...-2].join("-")

        if included.any?
          next if not included.include?(package)
        end

        puts "<8>[<7>+<8>] <10>#{package} <2>#{version}".colorize

        result   = []
        defaults = {}

        Zlib::GzipReader.open(mtree_path) do |io|
          lines = io.each_line.drop(1)
         
          lines.each do |line|
            path, *expected = line.split
            expected = expected.map { |opt| opt.split("=") }.to_h

            if path == "/set"
              defaults = expected
              next
            end

            path = path[1..-1] if path[0] == "."
            path = path.gsub(/\\(\d{3})/) { |m| $1.to_i(8).chr } # unescape \### codes

            # next if expected["type"] == "dir"
            next if SKIP_FILES.include?(path)

            expected = defaults.merge(expected)
            lstat    = File.lstat(path)

            errors = expected.map do |key, val|
              case key
              when "type"
                compare("type", lstat.ftype[0...val.size], val)
              when "link"
                next if val == "/dev/null"
                compare("link", File.readlink(path), val)
              when "gid"
                compare("gid", lstat.gid, val.to_i)
              when "uid"
                compare("uid", lstat.uid, val.to_i)
              when "mode"
                compare("mode", "%o" % (lstat.mode & 0xFFF), val)
              when "size"
                compare("size", lstat.size, val.to_i)
              when "time"
                next if expected["type"] == "dir"
                next if expected["link"] == "/dev/null"
                compare("time", lstat.mtime.to_i, val.to_i)
              when "sha256digest"
                compare("sha256digest", Digest::SHA256.file(path).hexdigest, val)
              when "md5digest"
                next if expected["sha256digest"]
                compare("md5digest", Digest::MD5.file(path).hexdigest, val)
              else
                raise "Unknown key: #{key}=#{val}"
              end
            end.compact

            if errors.any?
              puts "    <4>[<12>*<4>] <11>#{path}".colorize
              errors.each do |key, a, e| # a=actual, e=expected
                puts "        <7>expected <14>#{key} <7>to be <2>#{e} <7>but was <4>#{a}".colorize
                result << [path, "expected #{key.inspect} to be #{e.inspect} but was #{a.inspect}"]
              end
            end
          rescue Errno::EACCES
            puts "    <1>[<9>!<1>] <11>Can't read <7>#{path} <8>(<9>permission denied<8>)".colorize
            result << [path, "permission denied"]
          rescue Errno::ENOENT
            puts "    <4>[<12>?<4>] <12>Missing file <15>#{path}".colorize
            result << [path, "missing"]
          end
        end # gzip

        report << [package, result] if result.any?
      end # mtree 

      puts
      puts "#{report.size} packages with errors (#{report.map { |result| result.size }.sum} errors total)"
      puts

      if report.any?
        puts "Packages with problems:"
        report.each do |package, errors|
          puts "  #{package} (#{errors.size} errors)"
        end
      end
    end # verify!

  end # PacmanAuditor
end # UPM
