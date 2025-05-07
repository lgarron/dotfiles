# Bootstrap

BREWFILE_FOLDER = ./setup/Brewfiles
MAC_ADD_SHORTCUT = ./setup/scripts/mac-add-shortcut.fish
MAC_SYSTEM_DEFAULTS = ./setup/scripts/mac-system-defaults.fish
MAC_APP_DEFAULTS = ./setup/scripts/mac-app-defaults.fish

# Main Installations

.PHONY: mac-setup
mac-setup: \
	mac-homebrew \
	mac-setup-sudo \
	mac-system-defaults \
	mac-keyboard-shortcuts \
	mac-file-defaults \
	mac-commandline-core \
	mac-apps-core \
	mac-app-store-apps-core 

# Frontload `sudo` operations to avoid 
.PHONY: mac-setup-sudo
mac-setup-sudo: \
	mac-homebrew \
	mac-commandline-bootstrap \
	mac-fish-default-shell \
	prefer-wired-over-wireless-for-SMB \
	mac-set-finder-sidebar
	make mac-dock-setup

.PHONY: mac-setup-bulk
mac-setup-bulk: \
	mac-apps-bulk \
	mac-commandline-bulk \
	mac-app-store-apps-bulk
	make mac-dock-setup

# TODO: Use installation path instead of .PHONY?
.PHONY: mac-homebrew
mac-homebrew:
	./setup/scripts/install-homebrew.bash

# Definitions

.PHONY: mac-fish-default-shell
mac-fish-default-shell: mac-commandline-core
	cat /etc/shells | grep "`command -v fish`" > /dev/null || echo "`command -v fish`" | sudo tee -a /etc/shells
	dscl . -read /Users/${USER} UserShell | grep "fish$$" || chsh -s "`command -v fish`"

.PHONY: mac-system-defaults
mac-system-defaults:
	${MAC_SYSTEM_DEFAULTS}

.PHONY: mac-app-defaults
mac-app-defaults:
	${MAC_APP_DEFAULTS}

.PHONY: mac-set-finder-sidebar
mac-set-finder-sidebar:
	./setup/scripts/mac-set-finder-sidebar.fish

.PHONY: mac-keyboard-shortcuts
mac-keyboard-shortcuts:
	# Global
	${MAC_ADD_SHORTCUT} "NSGlobalDomain"            "Emoji & Symbols"          "^⇧⌘ "
	# Chrome
	${MAC_ADD_SHORTCUT} "com.google.Chrome"         "Extensions"               "⇧⌘E"
	${MAC_ADD_SHORTCUT} "com.google.Chrome.canary"  "Extensions"               "⇧⌘E"
	${MAC_ADD_SHORTCUT} "org.chromium.Chromium"     "Extensions"               "⇧⌘E"
	# Paste and Match Style
	${MAC_ADD_SHORTCUT} "com.tinyspeck.slackmacgap" "Paste and Match Style"    "⇧⌘V"
	${MAC_ADD_SHORTCUT} "com.apple.iWork.Pages"     "Paste and Match Style"    "⇧⌘V"
	${MAC_ADD_SHORTCUT} "com.bloombuilt.dayone-mac" "Paste as Plain Text"      "⇧⌘V"
	# Export
	${MAC_ADD_SHORTCUT} "com.bloombuilt.dayone-mac" "JSON"                     "⇧⌘E"
	${MAC_ADD_SHORTCUT} "com.apple.iMovieApp"       "File…"                    "⇧⌘E"
	${MAC_ADD_SHORTCUT} "com.apple.iWork.Pages"     "PDF…"                     "⇧⌘E"
	${MAC_ADD_SHORTCUT} "com.apple.garageband10"    "Export Song to Disk…"     "⇧⌘E"
	${MAC_ADD_SHORTCUT} "com.adobe.mas.lightroomCC" "Export…"                  "⇧⌘E"
	${MAC_ADD_SHORTCUT} "com.adobe.mas.lightroomCC" "Edit in Photoshop…"       "⇧⌘P"
	${MAC_ADD_SHORTCUT} "com.apple.FinalCut"        "'HEVC 8-bit Rec. 709 (auto bit rate)…'" "⇧⌘E"
	# Consistency with other programs
	# ${MAC_ADD_SHORTCUT} "com.apple.AddressBook"   "Edit Card"                "⌘E"
	${MAC_ADD_SHORTCUT} "com.apple.Safari"          "Reload Page From Origin"  "⇧⌘R"
	${MAC_ADD_SHORTCUT} "org.audacityteam.audacity" "Save Project As…"         "⇧⌘S"
	${MAC_ADD_SHORTCUT} "org.audacityteam.audacity" "Change Tempo…"            "⇧⌘T"
	# Final Cut Project
	${MAC_ADD_SHORTCUT} "com.apple.FinalCut"        "Organize — big video"        "^⇧⌘1"
	${MAC_ADD_SHORTCUT} "com.apple.FinalCut"        "Color & Effects — big video" "^⇧⌘2"
	# Misc
	${MAC_ADD_SHORTCUT} "com.apple.Music"           "as Songs"                 "⌘2"
	${MAC_ADD_SHORTCUT} "com.bambulab.bambu-studio" "Redo"                     "⇧⌘Z"
	${MAC_ADD_SHORTCUT} "org.openscad.OpenSCAD"     "Reset View"               "⇧⌘R"
	# TODO: we need to specify a longer menu path, as there are multiple menu item (leaves) named `Local`.
	# The settings UI supports this, but passing the same string here doesn't work (even with extra quoting).
	# ${MAC_ADD_SHORTCUT} "com.wolfram.Mathematica"   "Evaluation->Quit Kernel->Local"                    "^D"
	${MAC_ADD_SHORTCUT} "com.wolfram.Mathematica"   "Evaluate Initialization Cells"                    "^⌘I"
	

.PHONY: mac-file-defaults
mac-file-defaults:
	which duti || brew install duti

	# File formats

	duti -s com.google.Chrome public.url all
	duti -s com.google.Chrome public.svg-image all
	duti -s com.google.Chrome http all
	duti -s com.google.Chrome https all

	duti -s com.microsoft.vscode public.data all
	duti -s com.microsoft.vscode public.plain-text all
	-duti -s com.microsoft.vscode net.daringfireball.markdown all \
		|| echo -e "\n\nCannot set HTML handler at install time. Run later or right-click an HTML file in Finder to set as default.\n\n"
	duti -s com.microsoft.vscode public.json all
	duti -s com.microsoft.vscode public.python-script all
	-duti -s com.microsoft.vscode public.xml all
	# TODO: public.source-code?
	duti -s com.microsoft.vscode public.c-source
	duti -s com.microsoft.vscode public.c-header
	duti -s com.microsoft.vscode public.c-plus-plus-source
	duti -s com.microsoft.vscode public.source-code
	duti -s com.microsoft.vscode public.com.netscape.javascript-source
	duti -s com.microsoft.vscode public.yaml

	duti -s com.apple.quicktimeplayerx com.microsoft.waveform-audio all # wav
	duti -s com.apple.quicktimeplayerx com.apple.m4v-video all
	duti -s com.apple.quicktimeplayerx com.apple.m4a-audio all
	duti -s com.apple.quicktimeplayerx org.xiph.flac all
	duti -s com.apple.quicktimeplayerx public.mp3 all

	duti -s org.videolan.vlc public.playlist
	duti -s org.videolan.vlc public.m3u-playlist

	# https://github.com/moretension/duti/issues/29
	-duti -s com.google.Chrome org.ietf.mhtml all \
		|| echo -e "\n\nCannot set HTML handler at install time. Run later or right-click an HTML file in Finder to set as default.\n\n"
	-duti -s com.google.Chrome public.html all \
		|| echo -e "\n\nCannot set HTML handler at install time. Run later or right-click an HTML file in Finder to set as default.\n\n"

BREWFILE_TARGETS = \
	mac-app-store-apps-core \
	mac-apps-core \
	mac-apps-server \
	mac-commandline-bootstrap \
	mac-commandline-core \
	mac-commandline-bulk

.PHONY: $(BREWFILE_TARGETS)
$(BREWFILE_TARGETS):
	brew bundle --file=${BREWFILE_FOLDER}/$@.txt

BREWFILE_APPS_TARGETS = \
	mac-app-store-apps-bulk \
	mac-apps-bulk 

.PHONY: $(BREWFILE_APPS_TARGETS)
$(BREWFILE_APPS_TARGETS):
	brew bundle --file=${BREWFILE_FOLDER}/$@.txt
	make mac-app-defaults # Easiest way to ensure these get written.
	qlmanage -r
	pkill quicklook


# Dock

.PHONY: mac-dock-setup
mac-dock-setup:
	defaults write com.apple.dock persistent-apps -array "{}"

	test -d "/Applications/Toggle Screen Sharing Resolution.app/" && ./setup/scripts/mac-dock-add-app.fish "/Applications/Toggle Screen Sharing Resolution.app" || echo "Skipping…"
	./setup/scripts/mac-dock-add-app.fish "/System/Applications/Utilities/Activity Monitor.app"
	./setup/scripts/mac-dock-add-app.fish "/Applications/Quicksilver.app"
	./setup/scripts/mac-dock-add-app.fish "/Applications/Visual Studio Code.app"
	./setup/scripts/mac-dock-add-app.fish "/Applications/Google Chrome.app"
	./setup/scripts/mac-dock-add-app.fish "/Applications/Obsidian.app"
	test -d "/Applications/Linear.app/" && ./setup/scripts/mac-dock-add-app.fish "/Applications/Linear.app" || echo "Skipping…"

	defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'

	./setup/scripts/mac-dock-add-app.fish "/Applications/Slack.app"
	./setup/scripts/mac-dock-add-app.fish "/Applications/Discord.app"

	defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'

	killall Dock


.PHONY: mac-dock-setup-pythagoras-extras
mac-dock-setup-pythagoras-extras:

	./setup/scripts/mac-dock-add-app.fish "/Applications/Adobe Lightroom.app"
	./setup/scripts/mac-dock-add-app.fish "/Applications/Arq.app"
	./setup/scripts/mac-dock-add-app.fish "/Applications/Syncthing.app"
	./setup/scripts/mac-dock-add-app.fish "/Applications/Dropbox.app"
	./setup/scripts/mac-dock-add-app.fish "/System/Applications/Mail.app"
	./setup/scripts/mac-dock-add-app.fish "/Applications/Google Drive.app"
	./setup/scripts/mac-dock-add-app.fish "/Applications/OneDrive.app"

	defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'

	killall Dock

# Misc

.PHONY: prefer-wired-over-wireless-for-SMB
prefer-wired-over-wireless-for-SMB:
	# TODO: turn this into a config script with auto `sudo`.
	cat /etc/nsmb.conf | grep "mc_prefer_wired=yes" || echo "[default]\nmc_prefer_wired=yes" | sudo tee -a /etc/nsmb.conf # https://support.apple.com/en-us/102010

.PHONY: watch-for-plist-changes
watch-for-plist-changes:
	command -v plistwatch || go install github.com/catilac/plistwatch@latest
	plistwatch | grep -v "ContextStoreAgent"
