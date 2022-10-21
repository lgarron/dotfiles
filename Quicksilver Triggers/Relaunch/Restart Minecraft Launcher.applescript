try
	do shell script "killall launcher"
end try
do shell script "open -a Minecraft --args --skipUpdate"
# tell application "Minecraft" to activate