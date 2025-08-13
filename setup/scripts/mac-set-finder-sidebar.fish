#!/usr/bin/env fish

# TODO: figure out how to make this more declarative while taking `sudo` permission into account.
command -v mysides || brew install --cask mysides

function to_file_url
    printf "file://%s" (string escape --style url $argv[1])
end

set -l _CURRENT_HOSTNAME (hostname -s)
if contains $_CURRENT_HOSTNAME Germain

    # TODO: this permission prompt requires user interaction, and doesn't work over e.g. SSH?
    sfltool clear com.apple.LSSharedFileList.FavoriteItems

    mysides add lgarron (to_file_url "$HOME")
    mysides add Downloads (to_file_url "$HOME/Downloads/")
    mysides add Uploads (to_file_url "$HOME/Uploads/")
    mysides add "iCloud Drive" (to_file_url "$HOME/Library/Mobile Documents/com~apple~CloudDocs")
    mysides add Dropbox (to_file_url "$HOME/Dropbox/")
    mysides add "3D Printing" (to_file_url "$HOME/Dropbox/3D Printing/")
    mysides add Volumes (to_file_url "/Volumes/")
    mysides add "Trenzalore Locations" (to_file_url "/Volumes/Trenzalore/Meta/Trenzalore Locations/")
    mysides add 2025 (to_file_url "/Volumes/Trenzalore/Video Editing/2025/")

else if contains $_CURRENT_HOSTNAME Pythagoras

    # TODO: this permission prompt requires user interaction, and doesn't work over e.g. SSH?
    sfltool clear com.apple.LSSharedFileList.FavoriteItems

    mysides add lgarron (to_file_url "/Users/lgarron/")
    mysides add Dropbox (to_file_url "/Volumes/Samos/.CloudStorage/Data/Dropbox/")
    mysides add "Google Drive" (to_file_url "/Users/lgarron/Google Drive/")
    mysides add OneDrive-Personal (to_file_url "/Users/lgarron/Library/CloudStorage/OneDrive-Personal/")
    mysides add Downloads (to_file_url "/Users/lgarron/Downloads/")
    mysides add Desktop (to_file_url "/Users/lgarron/Desktop/")
    mysides add Volumes (to_file_url "/Volumes/")
    mysides add 2025 (to_file_url "/Volumes/Trenzalore/Video Editing/2025/")
    mysides add "Trenzalore Locations" (to_file_url "/Volumes/Trenzalore/Meta/Trenzalore Locations/")
    mysides add "HEVC archived.savedSearch" (to_file_url "/Users/lgarron/Library/Saved Searches/HEVC archived.savedSearch")
    mysides add "HEVC archived (from testing).savedSearch" (to_file_url "/Users/lgarron/Library/Saved Searches/HEVC archived (from testing).savedSearch")

else

    echo "Unrecognized machine. Leaving the Finder sidebar alone."

end
