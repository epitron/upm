# upm: Universal Package Manager

## Concept:

Wraps all known package managers to provide a consistent and pretty interface, along with advanced features not supported by all tools, such as rollback and pinning.

All tools will give you modern, pretty, colourful, piped-to-less output, and you'll only have to remember one consistent set of commands. It'll also prompt you with a text UI whenever faced with ambiguity.

## Usage:

```
upm <command> <pkg>
up <command> <pkg>
u <command> <pkg>
```

## Commands:

* `install`
* `remove`
* `build` - compile a package from source and install it
* `search` - using the fastest known API or service
* `list` - show all packages, or the contents of a specific package
* `info` - show metadata about a package
* `sync`/`update` - retrieve the latest package list or manifest
* `upgrade` - install new versions of all packages
* `pin` - pinning a package means it won't be automatically upgraded
* `rollback` - revert to an earlier version of a package (including its dependencies)
* `log` - show history of package installs 
* `packagers` - detect installed package managers, and pick which ones upm should wrap
* `sources`/`mirrors` - select remote repositories and mirrors
* `verfiy` - verifies the integrity of installed files
* `clean` - clear out the local package cache
* `monitor` - ad-hoc package manager for custom installations (like instmon)
* `keys` - keyrings and package authentication
* `default` - configure the action to take when no arguments are passed to "upm" (defaults to "os:update")

### Any command that takes a package name can be prefixed with the package tool's namespace:

```
os:<pkg> -- automatically select the package manager for the current unix distribution
deb:<pkg> (or d: u:)
rpm:<pkg> (or yum: y:)
bsd:<pkg> (or b:)
ruby:<pkg> (or r: gem:)
python:<pkg> (or py: p: pip:)
```

### ...or suffixed with its file extension:

```
<pkg>.gem
<pkg>.deb
<pkg>.rpm
<pkg>.pip
```

## Package tools to wrap:

* Arch: `pacman`/`aur`/`abs` (svn mirror)
* Debian/Ubuntu: `apt-get`/`dpkg` (+ curated list of ppa's)
* RedHat/Fedora/Centos: `yum`/`rpm`
* Mac OSX: `brew`/`fink`/`ports`
* FreeBSD: `pkg`/`ports`
* OpenBSD: `pkg_add`/`ports`
* NetBSD: `pkgin`/`ports`
* Windows: `apt-cyg`/`mingw-get`/`nuget`/`Windows Update`/(as-yet-not-created package manager, "winget")
* Wine: `winetricks`
* Ruby: `rubygems`
* Python: `pip`/`easy_install`
* Javascript: `npm`
* Clojure: `leiningen`
* Java: `gradle`
* Erlang: `rebar`
* Scala: `sbt`
* Rust: `cargo`
* R: `cran`
* Lua: `rocks`
* Julia: `Pkg`
* Haskell: `cabal`
* Perl: `cpan`
* go: `go-get`

...[and many more!](https://en.wikipedia.org/wiki/List_of_software_package_management_systems)


## What it might look like:

Info:

![acs](https://raw.githubusercontent.com/epitron/scripts/master/screenshots/acs.png)

Log:

![paclog](https://raw.githubusercontent.com/epitron/scripts/master/screenshots/paclog.png)

Rollback:

![pacman-rollback](https://raw.githubusercontent.com/epitron/scripts/master/screenshots/pacman-rollback.png)

## TODOs:

* Use the pretty text-mode UI that passenger-install uses
* Context-dependent operation
  * eg: if you're in a ruby project's directory, set the 'ruby' namespace to highest priority
