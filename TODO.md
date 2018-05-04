# TODO

## More package managers

Currently missing:
* RedHat/Fedora/CentOS
* OSX
* FreeBSD
* OpenBSD
* SuSE

## Abbrev cmds

* eg: upm install => upm i => u i

## Dependency-fetching features

* Use upm to fetch dependencies for any library or script, across any language.
* Some kind of manifest file (or personifest, to be politically correct)
* This is a little like bundler, npm, etc., but for any type of package.

## Ability to install any package from any OS to the user's home directory

Slurps up the packages and their dependencies, then unpacks them into ~/.upm/{bin,lib} or something.
(Like nix?)

Related tool: intoli/exodus

## fzf

Use fzf for "list" output (or other commands that require selecting, like "remove")

## Proper ARGV parser

* Something better than "command, *args = ARGV" (with "--help" available, at the very least.)

## Streaming pipes

* Make the `run` command able to grep the output while streaming the results to the screen.
* Make run pretend to be a tty, so I don't need `--color=always`.
* Use spawn, like so:
  ```
r,w = IO.pipe
spawn(*%w[echo hello world], out: w)
spawn(*%w[tr a-z A-Z], in: r)
```

## Figure out how to integrate language package managers

* The packages that you can get through gem/pip/luarocks/etc. are often duplicated in the OS-level package managers. Should there be a preference?
* Should the search command show matches from all available package tools? (There could be a configure step where the user says which package managers should be included, and which have preference)
* Possibilites: 
    * upm install --ruby <pkg>
    * upm install ruby:<pkg>,<pkg>
    * upm --ruby search <query>
    * upm ruby:search <query>
    * upm search os:<query>
    * Separate tool: `lpm search <query>` searches only language packages 
* Add detectors for language-specific package-managers
* Help screen needs to display language-specific package managers
* `upm help --ruby` should show available ruby commands

## Give identical output on every platform

* Requires parsing the output of every command into a canonical format, or reading the package databases directly.

## apt: Integrate 'acs' wrapper script

## Evaluate UPM::Tool.new block in an instance of an anonymous subclass of UPM::Tool

This will allow tools to create classes and modules inside the UPM::Tool block without namespace collisions

## Themes?

Why not!

## Mirror Selector

Do a ping test on available mirrors, and use fzf to select.


