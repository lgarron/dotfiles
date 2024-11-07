# [`lgarron`](https://github.com/lgarron)'s scripts

Many scripts can be installed using: <https://github.com/lgarron/homebrew-lgarron/>

Many scripts are also written in [`fish`](https://fishshell.com/).

## `app-tools`

### `editor-open`

Open a Markdown file in either Obsidian (if in a relevant folder) or VSCode.

### `launch-fish-in-dir`

Launch `fish` in the directory of the specified path.

### `openscad-auto`

Run `openscad` to convert `.scad` file to `.3mf` or `.stl` file with defaults.

### `restart-qs`

Restart [Quicksilver](https://qsapp.com/).

## `audio`

### `flacify`

Convert to `flac`

### `mp3ify`

Convert to `.mp3` with high (but not maximum) quality.

### `wavify`

Convert to `.wav`

## `focus-modes`

### `gaming-mode-on`

Commands to run for turning on gaming mode.

### `gaming-mode-off`

Commands to run for turning off gaming mode.

## `games`

### `civ6-auto-resolution`

Automatically set the full screen resolution for Civilization (with hardcoded values).

## `git`

### `gclone`

Clone the given URL to `~/Code/git/github.com/[user]/[repo]/`. Useful to combine with `chrometab`, or [using QS](https://github.com/lgarron/dotfiles/blob/f5b435e3701988b070920ef1f31ef6afb2384ca8/Quicksilver%20Triggers/Google/Clone%20GitHub%20Repo%20from%20Chrome.applescript).

### `git-distance`

Calculate the distance from the current branch (or any branch) to another branch, in terms of # of unique commits on each since the last common ancestor.

### `node_crunchule`

Compress any `node_modules` in the current or ancestor folders (useful to reduce the number of files on disk for a dormant repo, which can make system backups faster to diff).

### `rmbranch`

Remove `git` branches locally and remotely.

### `rmtag`

Remove `git` tags locally and remotely.

### `tagpush`

Push and update `git` tags automatically.

### `version`

Get the current or previous project version.

## `graphics`

### `jpeg-optimize`

Optimise a single file using `jpeg-recompress`.

### `jpeg-optimize-all`

Optimise all `.jpg` files in the current folder using `jpeg-recompress`.

### `jpegrescan`

A script to optimize JPEGs, by Loren Merritt

### `jpgcrush`

A script to optimize JPEGs, by Loren Merritt.

### `resize`

Resize an image (padding with transparency if needed).

### `square`

Resize an image into a square (padding with transparency if needed).

### `web-app-images`

Automatically create resized versions of an icon for web app use cases.

### `whiteboard`

Convert an image into an optimized black-and-white file using [this gist by Leland Batey](https://gist.github.com/lelandbatey/8677901).

## `maestral`

### `dbx-link`

Copy a link to the given path (relative to the current working dir, or absolute), creating it if needed.

### `dbx-web`

Open a link to the given path (relative to the current working dir, or absolute) on the Dropbox website in the browser.

## `pack`

### `pack-logs`

Pack argument files into a `logs.7z` file. Example: `pack-logs *.log`

### `pack-pov`

Pack `.bmp` or `.png` files in a folder. Example: `pack-pov cube?????.png`

## `storage`

### `counter-file`

Maintains a simple JSON counter file.

### `dmgify`

Create a `.dmg` out of a folder. Can be as useful as a `.zip` file, but allows mounting and editing in macOS without any special tools. Example: `dmgify ./path/to/folder`

### `generate-web-folder-index`

Create a simple HTML folder index for the given input files.

### `reveal-sd-card-backup-dcim`

Given either the source or destination of a `DCIM` file backed up using [`sd-card-backup`](https://github.com/lgarron/sd-card-backup), reveal the other.

## `sudo`

### `thermal-pressure`

Get thermal pressure on macOS without `sudo`ing every time.

### `niceplz-sudo`

Run `niceplz` without `sudo`ing every time.

## `system`

### `app-screenshot`

Take a macOS screenshot and save it with with a folder and file name based on the current foreground app. (Currently hardcoded to my own Dropbox path.)

### `assign-icon`

Assign an icon file to a file/folder.

### `macos-charging-watts`

Print the number of watts supported by the current charger.

### `niceplz`

Script to set the nicess of processes based on `~/.config/niceplz/niceplz.json`.

### `pnice`

Set the nicess of processes by matching (a substring of) process names. Invokes `sudo` if needed.

### `pnicest`

Set a process to maximum niceness using `pnice`.

### `touch-id-sudo-config`

Enable Touch ID for sudo commands in shells by adding `pam_tid.so` to `/private/etc/pam.d/sudo`. Useful after every macOS update. Example: `touch-id-sudo-config enable`

### `map`

Super simple parallization scripts. Example: `map process file1.txt file2.txt`

### `portkill`

Run `kill -9` for any processes using a given port. Example: `portkill 8000`

### `set-remote-screen-sharing-resolution`

Set the remote screen sharing resolution for a given computer automatically. Hardcoded to a 5K monitor and the 16-inch MacBook Pro.

### `symlink-replace`

Replace a symlink with its target.

### `tailscale-exit-node`

Print the current Tailscale exit node if there is one, else exit with an error.

### `toggle-retina`

Toggle Retina display scaling. Requires [RDM](https://github.com/avibrazil/RDM) to be installed.

### `toggle-screen-sharing-resolution`

Toggle resolution for screen sharing. Requires [RDM](https://github.com/avibrazil/RDM) to be installed.

### `unixtime`

Print the current unix time in seconds. Equivalent to `date +%s` but easier to remember.

### `xdig`

A wrapper for `dig` that allows using `~/.config/dig/digrc` (XDG dir convention compatible) instead of `.digrc`, with reasonable fidelity.

## `video`

### `hevc`

Encode a video using HEVC for excellent archival quality.

### `30hzify`

Slow down a 120Hz video to 30hz.

### `120hzify`

Speed up a 30Hz video from 120Hz.

### `timelapse`

Timelapse a video by averaging frames.

## `web`

### `add-biome`

Install and configure [`biome`](https://biomejs.dev/) for a JS repo with my legacy defaults.

### `bun-roll`

Roll a dependency to the latest version and add using `bun`.

### `chrometab`

Get the current open Chrome tab.

### `npm-cost`

Calculate the cost of a given `npm` module by number of files and disk size, without modifying the current folder.

### `npm-roll`

Roll a dependency to the latest version and install using `npm`.

### `safaritab`

Get the current open Safari tab.

### `weblocify`

Create a `.webloc` file for the given URL. Example (using `chrometab` in `fish`): `weblocify (chrometab) bookmark-file.webloc`

### `ytflac`

Use `youtube-dl` to get a `.flac` file for a URL.

### `ytmp3`

Use `youtube-dl` to get a `.mp3` file for a URL.
