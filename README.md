# upm: Universal Package Manager

## Concept:

Wraps all known package managers to provide a consistent and pretty interface, along with advanced features not supported by all tools, such as like rollback and pinning.

## Usage:

```
upm <command> <pkg>
up <command> <pkg>
u <command> <pkg>
```

## Commands:

* list
* search
* install
* sync/update
* upgrade
* log - show history of package installs 
* pin
* rollback
* packagers - detect package systems, and enable/disable them
* sources/mirrors - select remote repositories and mirrors
* verfiy - verifies integrity of installed packages
* remove
* clean
* build
* monitor - ad-hoc package manager for custom installations (like instmon)
* keys - keyrings and package authentication
* default - configurable default action (defaults to update only the OS)

### Install, search, and remove can prefix the package name with a namespace:

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

* Build using the pretty text-mode UI that passenger-install uses
* Context-dependent operation
  * if you're in a ruby project, prioritize the 'ruby' namespace
