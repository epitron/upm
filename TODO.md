# TODO

## More package managers

Currently missing:
* RedHat/Fedora/CentOS
* OSX
* FreeBSD
* OpenBSD
* SuSE

## fzf

Use fzf for "list" output (or other commands that require selecting, like "remove")

## Proper ARGV parser

* Something better than "command, *args = ARGV" (with "--help" available, at the very least.)

## Streaming pipes

* Make the `run` command able to grep the output while streaming the results to the screen.
* Make run pretend to be a tty, so I don't need `--color=always`.

## Figure out how to integrate language package managers

* The packages that you can get through gem/pip/luarocks/etc. are often duplicated in the OS-level package managers. Should there be a preference?
* Should the search command show matches from all available package tools? (There could be a configure step where the user says which package managers should be included, and which have preference)
* Possibilites: 
    * upm install --ruby <pkg>
    * upm install ruby:<pkg>,<pkg>
    * upm --ruby search <query>
    * upm ruby:search <query>
    * upm search os:<query>
* Add detectors for language-specific package-managers
* Help screen needs to display language-specific package managers
* `upm help --ruby` should show available ruby commands

## Mirror Selector

* Do a ping test on available mirrors, and use fzf to select
