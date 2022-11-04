/datum/hud/roundend
	click_check = 0
	var/atom/movable/screen/countdown

	New()

		src.countdown = create_screen("roundend", "Round End Countdown", null, "", "NORTH,CENTER", HUD_LAYER_3)
		countdown.maptext = ""
		countdown.maptext_width = 480
		countdown.maptext_x = -(480 / 2) + 16
		countdown.maptext_y = -320
		countdown.maptext_height = 320
		countdown.plane = 100
		..()

	proc/update_time(var/seconds)
		countdown.maptext = "<span class='c ol vga vt' style='background: #00000080;'>This round will end in<br><span style='font-size: 24px;'>[seconds]</span></span>"

	proc/update_delayed()
		countdown.maptext = "<span class='c ol vga vt' style='background: #00000080;'>The round end has been delayed by an admin.<br>It will end once they remove the delay.</span>"

