on shell(command)
	do shell script "/opt/homebrew/bin/trampoline " & command
end shell

shell("nohup /Users/lgarron/Code/git/github.com/lgarron/dotfiles/scripts/system/eject-known-cards.ts --notify > /dev/null 2> /dev/null &")
