/datum/hud/tutorial
	var/atom/movable/screen/tutorial_step
	var/atom/movable/screen/tutorial_text

	New()
		..()
		src.tutorial_step = create_screen("tutorial_step", "Tutorial Step", null, "", "NORTH, CENTER", HUD_LAYER_3)
		src.tutorial_step.maptext = ""
		src.tutorial_step.maptext_width = 480
		src.tutorial_step.maptext_x = -(480 / 2) + 16
		src.tutorial_step.maptext_y = -320
		src.tutorial_step.maptext_height = 320
		src.tutorial_step.plane = PLANE_HUD
		src.tutorial_step.layer = 420

		src.tutorial_text = create_screen("tutorial_text", "Tutorial Text", null, "", "NORTH-1, CENTER", HUD_LAYER_3)
		src.tutorial_text.maptext = ""
		src.tutorial_text.maptext_width = 480
		src.tutorial_text.maptext_x = -(480 / 2) + 16
		src.tutorial_text.maptext_y = -320
		src.tutorial_text.maptext_height = 320
		src.tutorial_text.plane = PLANE_HUD
		src.tutorial_text.layer = 420

	proc/update_step(new_text)
		src.tutorial_step.maptext = "<span class='c ol vga vt' style='background: #00000080;'>[new_text]</span>"


	proc/update_text(new_text)
		src.tutorial_text.maptext = "<span class='c ol vt' style='background: #00000080;'>[new_text]</span>"
