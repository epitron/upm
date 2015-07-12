# upm: Universal Package Manager

## Concept:

Wraps all known package managers to provide a consistent and pretty interface, along with advanced features not supported by all tools, such as rollback and pinning.

All tools will give you modern, pretty, colourful, piped-to-less output, and you'll only have to remember one set of nice commands. It'll also prompt you with a nice text UI whenever it's faced with ambiguity.

## Usage:

```
upm <command> <pkg>
up <command> <pkg>
u <command> <pkg>
```

## Commands:

* install
* remove
* build - compile a package from source and install it
* search - using the fastest known API or service
* list - show all packages, or the contents of a specific package
* info - show metadata about a package
* sync/update - retrieve the latest package list or manifest
* upgrade - install new versions of all packages
* pin - pinning a package means it won't be automatically upgraded
* rollback - revert to an earlier version of a package (including its dependencies)
* log - show history of package installs 
* packagers - detect installed package managers, and pick which ones upm should wrap
* sources/mirrors - select remote repositories and mirrors
* verfiy - verifies integrity of installed packages
* clean - clear out the local package cache
* monitor - ad-hoc package manager for custom installations (like instmon)
* keys - keyrings and package authentication
* default - configure the action to take when no arguments are passed to "upm" (defaults to "os:update")

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

* OpenBSD: pkg_add
* FreeBSD: pkg
* RedHat/Fedora/Centos: yum/rpm
* Debian/Ubuntu: apt-get/dpkg (+ curated list of ppa's)
* Windows: apt-cyg/nuget/"winget" (new package manager)
* Arch: pacman/aur/abs (svn mirror)
* Mac OSX: brew/fink
* Python: pip/easy_install
* Ruby: rubygems
* Haskell: cabal
* Perl: cpan
* go: go-get
* Java: ?

...[and many more!](https://en.wikipedia.org/wiki/List_of_software_package_management_systems)


## TODOs:

* Use the pretty text-mode UI that passenger-install uses
* Context-dependent operation
  * if you're in a ruby project's directory, set the 'ruby' namespace to highest priority
