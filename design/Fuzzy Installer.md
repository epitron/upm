# Fuzzy Installer

## Concept 

'upm install <pkg query>' performs a search

If there's one match, install it; if there are multiple matches, show ranked results and let the user pick one (fzf-like picker, but with a hotkey that can expand descriptions).

Ranking of packages by source use statistics and heuristics
- Which version is newest?
- Which version is more stable?
- What has the user picked in the past? (eg: a distro's global ruby-<gem> package vs a globally installed gem vs a locally installed gem)
- What tools are installed? (docker? gem?)
- Which package is less likely to break stuff? (some package managers are better than others (*cough*pip))
- Is it a service that should be instaled in a container?

## Depends on

- A database of package aliases
- A ranking algorithm
	- Package type prioritization (manually specified or machine learned, per-package rules based on all users who installed it)
	- 
- Distributed statistics
	- Users can anonymously donate their stats
	- Stats are all public
	- Ranking algorithm can run locally or on a distributed system

# 