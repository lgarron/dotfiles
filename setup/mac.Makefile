# Bootstrap

BREWFILE_FOLDER = ./setup/Brewfiles
MAC_ADD_SHORTCUT = ./setup/script/mac-add-shortcut.fish
MAC_WRITE_DEFAULTS = ./setup/script/mac-write-defaults.fish

# TODO: Use installation path instead of .PHONY?
.PHONY: mac-homebrew
mac-homebrew: ${HOMEBREW_PATH}

${HOMEBREW_PATH}:
	echo "Skipping Homebrew installation"

# Main Installations

.PHONY: mac-setup
mac-setup: \
	mac-homebrew \
	mac-defaults \
	mac-keyboard-shortcuts \
	mac-file-defaults \
	mac-commandline-core \
	mac-apps-core \
	mac-fish-default-shell

.PHONY: mac-setup-extra
mac-setup-extra: \
	mac-apps-extra \
	mac-commandline-extra \
	mac-quicklook

# Definitions

.PHONY: mac-fish-default-shell
mac-fish-default-shell: mac-commandline-core
	cat /etc/shells | grep "`which fish`" → /dev/null || echo "`which fish`" | sudo tee -a /etc/shells
	chsh -s "`which fish`"

.PHONY: mac-defaults
mac-defaults:
	${MAC_WRITE_DEFAULTS}

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
	# Misc
	${MAC_ADD_SHORTCUT} "com.apple.Music"           "as Songs"                 "⌘2"

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

.PHONY: mac-commandline-core
mac-commandline-core:
	brew bundle --file=${BREWFILE_FOLDER}/commandline-core.txt

.PHONY: mac-commandline-extra
mac-commandline-extra:
	brew bundle --file=${BREWFILE_FOLDER}/commandline-extra.txt
	gem install jekyll
	pip install httpie

.PHONY: mac-apps-core
mac-apps-core:
	brew bundle --file=${BREWFILE_FOLDER}/core.txt

#TODO: Split apps by machine?
.PHONY: mac-apps-extra
mac-apps-extra: mac-browsers
	brew bundle --file=${BREWFILE_FOLDER}/extra.txt

.PHONY: mac-quicklook
mac-quicklook:
	brew bundle --file=${BREWFILE_FOLDER}/quicklook.txt

	# https://gregbrown.co/code/typescript-quicklook
	@echo "Set Quicklook to handle .ts files as text (TypeScript) instead of video."
	touch /tmp/ts-file-extension-test.ts
	# TODO: Make this idempotent.
	plutil \
		-insert "CFBundleDocumentTypes.0.LSItemContentTypes.1" \
		-string $(shell mdls -raw -name kMDItemContentType /tmp/ts-file-extension-test.ts) \
		${HOME}/Library/QuickLook/QLColorCode.qlgenerator/Contents/Info.plist

	qlmanage -r

.PHONY: mac-browsers
mac-browsers:
	brew bundle --file=${BREWFILE_FOLDER}/browsers.txt

# Dock

.PHONY: mac-dock-reset
mac-dock-reset:
	defaults write com.apple.dock persistent-apps -array "{}"
	killall Dock

.PHONY: mac-dock-right
mac-dock-right:
	defaults write com.apple.dock orientation right && killall Dock

.PHONY: mac-dock-left
mac-dock-left:
	defaults write com.apple.dock orientation left && killall Dock

.PHONY: mac-dock-bottom
mac-dock-bottom:
	defaults write com.apple.dock orientation bottom && killall Dock

.PHONY: mac-dock-add-spacer
mac-dock-add-spacer:
	defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'
	killall Dock
