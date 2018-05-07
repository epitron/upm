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

    COMMAND_HELP = {
      "install"          => "install a package",
      "remove/uninstall" => "remove a package",
      "build"            => "compile a package from source and install it",
      "search"           => "using the fastest known API or service",
      "list"             => "list installed packages (or search their names if extra arguments are supplied)",
      "info"             => "show metadata about a package",
      "update/sync"      => "retrieve the latest package list or manifest",
      "upgrade"          => "update package list and install updates",
      "download"         => "download package list and updates, but don't insatall them",
      "pin"              => "pinning a package means it won't be automatically upgraded",
      "rollback"         => "revert to an earlier version of a package (including its dependencies)",
      "log"              => "show history of package installs",
      "packagers"        => "detect installed package managers, and pick which ones upm should wrap",
      "mirrors/sources"  => "manage remote repositories and mirrors",
      "verfiy"           => "verify the integrity of installed files",
      "clean"            => "clear out the local package cache",
      "monitor"          => "ad-hoc package manager for custom installations (like instmon)",
      "keys"             => "keyrings and package authentication",
      "default"          => "configure the action to take when no arguments are passed to 'upm' (defaults to 'os:update')",
    }

    ALIASES = {
      "file"    => "files",
      "sync"    => "update",
      "sources" => "mirrors",
      "show"    => "info",
      "u"       => "upgrade",
      "i"       => "install",
      "d"       => "download",
      "s"       => "search",
      "f"       => "files",
      "r"       => "remove",
    }

    def initialize(name, &block)
      @name = name
      instance_eval(&block)

      @@tools[name] = self
    end

  end # class Tool

end # module UPM

