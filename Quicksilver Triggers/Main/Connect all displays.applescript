on shell(command)
	do shell script "env PATH=\"$PATH:/opt/homebrew/bin\" " & command
end shell

shell("/Users/lgarron/Code/git/github.com/lgarron/dotfiles/scripts/system/connect-all-displays.ts")
