-- eve-ng_wireshark.scpt by Matt Haedo
-- Fork of Stuart Fordham's UNL_WiresharkV2
-- https://www.802101.com/unetlab-and-wireshark-for-osx-update
-- To use, copy this code, paste into Apple Script Editor, and save as .app

on open location this_URL
	set get_date to do shell script "date +%Y%m%d-%H%M%S"
	set cap_URL to this_URL
	set AppleScript's text item delimiters to {"/"}
	set new_cap_HOST to text item 3 of cap_URL
	set new_cap_INT to text item 4 of cap_URL
	set capturefile to new_cap_INT & "-" & text 1 thru 15 of get_date
	tell application "Terminal"
		activate
		my makeTab()
		do script "mkfifo /tmp/" & capturefile & "&" in tab 1 of front window
		do script "wireshark -k -i /tmp/" & capturefile & "&" in tab 1 of front window
		do script "ssh root@" & new_cap_HOST & " tcpdump -U -i " & new_cap_INT & " -s 0 -w - > /tmp/" & capturefile in tab 1 of front window
	end tell
end open location

on makeTab()
	tell application "System Events" to keystroke "t" using {command down}
	delay 0.2
end makeTab