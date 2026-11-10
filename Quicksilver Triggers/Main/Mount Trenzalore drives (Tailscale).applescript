on shell(command)
	do shell script "/opt/homebrew/bin/trampoline " & command
end shell

shell("nohup /Users/lgarron/Code/git/github.com/lgarron/dotfiles/scripts/storage/mount-trenzalore-drives-tailscale.fish > /dev/null 2> /dev/null &")
