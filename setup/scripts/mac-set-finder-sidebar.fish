#!/usr/bin/env fish

# TODO: figure out how to make this more declarative while taking `sudo` permission into account.
command -v mysides || brew install --cask mysides

set -l _CURRENT_HOSTNAME (hostname -s)
if contains $_CURRENT_HOSTNAME "Germain"

  # TODO: this permission prompt requires user interaction, and doesn't work over e.g. SSH?
  sfltool clear com.apple.LSSharedFileList.FavoriteItems

  mysides add "lgarron" "file://$HOME"
  mysides add "Downloads" "file://$HOME/Downloads/"
  mysides add "Uploads" "file://$HOME/Uploads/"
  mysides add "iCloud Drive" "file://$HOME/Library/Mobile%20Documents/com~apple~CloudDocs"
  mysides add "Dropbox" "file://$HOME/Dropbox%20(Maestral)/"
  mysides add "3D printing" "file://$HOME/Dropbox%20(Maestral)/3D%20Printing/"
  mysides add "Volumes" "file:///Volumes/"
  mysides add "Trenzalore Locations" "file:///Volumes/Trenzalore/Meta/Trenzalore%20Locations/"
  mysides add "2025" "file:///Volumes/Trenzalore/Video%20Editing/2025/"

else if contains $_CURRENT_HOSTNAME "Pythagoras"

  # TODO: this permission prompt requires user interaction, and doesn't work over e.g. SSH?
  sfltool clear com.apple.LSSharedFileList.FavoriteItems

  mysides add "lgarron" "file:///Users/lgarron/"
  mysides add "Dropbox" "file:///Volumes/Samos/.CloudStorage/Data/Dropbox/"
  mysides add "Google Drive" "file:///Users/lgarron/Google%20Drive/"
  mysides add "OneDrive-Personal" "file:///Users/lgarron/Library/CloudStorage/OneDrive-Personal/"
  mysides add "Downloads" "file:///Users/lgarron/Downloads/"
  mysides add "Desktop" "file:///Users/lgarron/Desktop/"
  mysides add "Volumes" "file:///Volumes/"
  mysides add "2025" "file:///Volumes/Trenzalore/Video%20Editing/2025/"
  mysides add "Trenzalore Locations" "file:///Volumes/Trenzalore/Meta/Trenzalore%20Locations/"
  mysides add "HEVC archived.savedSearch" "file:///Users/lgarron/Library/Saved%20Searches/HEVC%20archived.savedSearch"
  mysides add "HEVC archived (from testing).savedSearch" "file:///Users/lgarron/Library/Saved%20Searches/HEVC%20archived%20(from%20testing).savedSearch"

else

  echo "Unrecognized machine. Leaving the Finder sidebar alone."

end
