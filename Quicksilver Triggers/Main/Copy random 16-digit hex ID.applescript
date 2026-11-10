on shell(command)
	do shell script "/opt/homebrew/bin/trampoline " & command
end shell

shell("openssl rand -hex 8 | tr -d \"\n\" | pbcopy")
