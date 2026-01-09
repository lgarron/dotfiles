on shell(command)
	do shell script "/Users/lgarron/Code/git/github.com/lgarron/dotfiles/setup/scripts/trampoline.fish " & command
end shell

shell("/Users/lgarron/Code/git/github.com/lgarron/dotfiles/scripts/system/screen-sharing.ts reconnect")
