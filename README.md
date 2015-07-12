# up: The Universal Package manager

## Usage:

```
up <command> <pkg>
```

## Commands

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

### All searches and package names can be prefixed with their namespace:

```
ruby:<pkg> (or r:)
deb:<pkg> (or d:)
rpm:<pkg>
python:<pkg>
py:<pkg>
pip:<pkg>
```

### ...or suffixed with its file extension:

```
<pkg>.gem
<pkg>.deb
<pkg>.rpm
<pkg>.pip
```

## Supported packagers:

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


## TODOs:

* Build using the pretty text-mode UI that passenger-install uses
* Context-dependent operation
  * if you're in a ruby project, prioritize the 'ruby' namespace
