require 'upm/tool_dsl'
require 'upm/tool_class_methods'

# os:<pkg> -- automatically select the package manager for the current unix distribution
# deb:<pkg> (or d: u:)
# rpm:<pkg> (or yum: y:)
# bsd:<pkg> (or b:)
# ruby:<pkg> (or r: gem:)
# python:<pkg>,<pkg> (or py: p: pip:)

module UPM

  class Tool

    @@tools = {}

    include UPM::Tool::DSL

    # TODO: Show unlisted commands

    COMMAND_HELP = {
      "install"          => "install a package",
      "remove/uninstall" => "remove a package",
      "search"           => "search packages",
      "update/sync"      => "retrieve the latest package list or manifest",
      "upgrade"          => "update package list and install updates",
      "search-sources"   => "search package source (for use with 'build' command)",
      "list"             => "list installed packages (or search their names if extra arguments are supplied)",
      "files"            => "list files in a package",
      "info/show"        => "show metadata about a package",
      "rdeps/depends"    => "reverse dependencies (which packages depend on this package?)",
      "locate"           => "search contents of packages (local or remote)",
      "selfupdate"       => "update the package manager",
      "download"         => "download package list and updates, but don't insatall them",
      "build"            => "build a package from source and install it",
      "selection/manual" => "list manually installed packages", # this should probably be a `list` option ("upm list --manually-added" or smth (would be nice: rewrite in go and use ipfs' arg parsing library))
      "pin"              => "pinning a package means it won't be automatically upgraded",
      "rollback"         => "revert to an earlier version of a package (including its dependencies)",
      "verify/check"     => "verify the integrity of packages' files on the filesystem",
      "repair"           => "fix corrupted packages",
      "audit/vulns"      => "show known vulnerabilities in installed packages",
      "log"              => "show history of package installs",
      "packagers"        => "detect installed package managers, and pick which ones upm should wrap",
      "clean"            => "clear out the local package cache",
      "orphans"          => "dependencies which are no longer needed",
      "monitor"          => "ad-hoc package manager for custom installations (like instmon)",
      "keys"             => "keyrings and package authentication",
      "default"          => "configure the action to take when no arguments are passed to 'upm' (defaults to 'os:update')",
      "stats"            => "show statistics about package database(s)",
      "rosetta"          => "show a table translations between all upm commands and equivalent the package manager commands",
      "repos/mirrors/sources/channels" => "manage subscriptions to remote repositories/mirrors/channels",
    }

    ALIASES = {
      "u"             => "upgrade",
      "i"             => "install",
      "d"             => "download",
      "s"             => "search",
      "f"             => "files",
      "r"             => "remove",
      "m"             => "mirrors",
      "file"          => "files",
      "vuln"          => "audit",
      "source-search" => "search-sources",
    }

    COMMAND_HELP.keys.each do |key|
      cmd, *alts = key.split("/")
      alts.each do |alt|
        ALIASES[alt] = cmd
      end
    end

    def initialize(name, &block)
      @name = name

      set_default :cache_dir, "~/.cache/upm"
      set_default :config_dir, "~/.cache/upm"
      set_default :max_database_age, 15*60 # 15 minutes

      instance_eval(&block)

      @@tools[name] = self
    end

  end # class Tool

end # module UPM

