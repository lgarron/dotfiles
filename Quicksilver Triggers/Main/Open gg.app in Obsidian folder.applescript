on shell(command)
	do shell script "/opt/homebrew/bin/trampoline " & command
end shell

# Note `--args` has some issues, but here we are calling it with a static value.
shell("killall gg ; open -a gg --args \"/Users/lgarron/Library/Mobile Documents/iCloud~md~obsidian/Documents/\" &")

