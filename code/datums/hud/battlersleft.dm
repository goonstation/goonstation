/datum/hud/battlersleft
	click_check = 0
	var/atom/movable/screen/battlersleft

	New()

		src.battlersleft = create_screen("battlersleft", "Battle Royale Players Left", null, "", "NORTH,CENTER", HUD_LAYER_3)
		battlersleft.maptext = ""
		battlersleft.maptext_width = 480
		battlersleft.maptext_x = -(480 / 2) + 16
		battlersleft.maptext_y = -320
		battlersleft.maptext_height = 320
		battlersleft.plane = 100
		..()

	proc/update_battlersleft(var/living_battlers)
		battlersleft.maptext = "<span class='c ol vga vt' style='background: #00000080;'>Players Left:<br><span style='font-size: 24px;'>[living_battlers]</span></span>"
