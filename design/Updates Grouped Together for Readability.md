# Updates Grouped Together for Readability

## Concept

The design of package update screens is pretty abysmal -- usually just a big blob of package names and versions. This can be improved.

## Groups

Packages can be grouped by any of the following:

- semantic version (MAJOR.MINOR.PATCH):
  - MAJOR: incompatible API changes
  - MINOR: backwards-compatible features added
  - PATCH: bugfixes
- package's category/tags
- which repository the package came from
- who packaged it
- a tree-view of package dependencies (useful for seeing dependency relationships during package updates)
