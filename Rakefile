gem_version = File.read("VERSION").strip
pkgname = "upm"

task :build do
  system "gem build .gemspec"
end
 
task :release => :build do
  system "gem push #{pkgname}-#{gem_version}.gem"
end

task :gem => :build

task :install => :build do
  system "gem install #{pkgname}-#{gem_version}.gem"
end
