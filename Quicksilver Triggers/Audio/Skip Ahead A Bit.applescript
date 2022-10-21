(*
"Replay Last Bit" for iTunes
written by Doug Adams
dougadams@mac.com

v2.0 september 9 2004
-- runs as a stay-open script
-- alternates between pausing and rewinding

v1.0 february 27 2004
initial release

Get more free AppleScripts and info on writing your own
at Doug's AppleScripts for iTunes
http://www.malcolmadams.com/itunes/
*)

-- change the number of seconds to rewind if you like
property secondsToSkip : 5

property iTunes_is_paused : false

on run
	rewindiTunes()
	set iTunes_is_paused to false
end run

-- every other call to reopen performs one of two tasks
on reopen
	if iTunes_is_paused then
		rewindiTunes()
		set iTunes_is_paused to false
	else
		tell application "Music" to pause
		set iTunes_is_paused to true
	end if
	-- tell application "Some Application" to activate
end reopen

-- handler to rewind the current track
to rewindiTunes()
	tell application "Music"
		if player state is not stopped then
			set pos to player position
			if (pos is less than ((finish of current track) - secondsToSkip)) then
				set player position to pos + secondsToSkip
				play
			end if
		end if
	end tell
end rewindiTunes

