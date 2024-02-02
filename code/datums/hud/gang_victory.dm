/datum/hud/gang_victory
	click_check = 0
	var/atom/movable/screen/text

	New(datum/gang/winning_gang)
		src.text = create_screen("gangvictory", "Gang Victory Display", null, "", "NORTH,CENTER", HUD_LAYER_3)
		text.maptext = "<span class='c ol vga vt' style='background: #00000080;font-size: 5;'>[winning_gang.gang_name] won the round!</span>"
		text.maptext_width = 600
		text.maptext_x = -(600 / 2) + 16
		text.maptext_y = -150
		text.maptext_height = 100
		text.plane = PLANE_HUD
		text.layer = 420
		..()
