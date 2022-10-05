This folder contains files that *would* be symlinks, except that the symlink would get overwritten. This:

1. makes `stow` error, and
2. makes it easy to lose track of changes without realizing.

So we identify and isolate such configs here, for now.
