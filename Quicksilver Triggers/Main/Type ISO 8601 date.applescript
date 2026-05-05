-- From https://gist.github.com/Glutexo/78c170e2e314f0eacc1a

(*
	The zero_pad function taken from:
	http://www.nineboxes.net/2009/10/an-applescript-function-to-zero-pad-integers/
*)
on zero_pad(value, string_length)
	set string_zeroes to ""
	set digits_to_pad to string_length - (length of (value as string))
	if digits_to_pad > 0 then
		repeat digits_to_pad times
			set string_zeroes to string_zeroes & "0" as string
		end repeat
	end if
	set padded_value to string_zeroes & value as string
	return padded_value
end zero_pad

set now to (current date)

set result to (year of now as integer) as string
set result to result & "-"
set result to result & zero_pad(month of now as integer, 2)
set result to result & "-"
set result to result & zero_pad(day of now as integer, 2)

tell application "System Events" to keystroke result
