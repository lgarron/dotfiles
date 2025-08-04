on shell(command)
	do shell script "env PATH=\"$PATH:/opt/homebrew/bin\" " & command
end shell

shell("openssl rand -hex 8 | tr -d \"\n\" | pbcopy")
