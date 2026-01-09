on shell(command)
	do shell script "/opt/homebrew/bin/trampoline " & command
end shell

shell("/Users/lgarron/Code/git/github.com/lgarron/dotfiles/scripts/system/screen-sharing.ts connect")
