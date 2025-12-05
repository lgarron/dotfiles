on shell(command)
	do shell script "env PATH=\"$PATH:/opt/homebrew/bin\" " & command
end shell

shell("nohup /Users/lgarron/Code/git/github.com/lgarron/dotfiles/scripts/system/eject-all-cards.ts --notify > /dev/null 2> /dev/null &")
