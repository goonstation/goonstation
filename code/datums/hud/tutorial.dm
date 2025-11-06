/datum/hud/tutorial
	var/atom/movable/screen/tutorial_step = null
	var/atom/movable/screen/tutorial_text = null
	var/atom/movable/screen/tutorial_sidebar = null
	var/atom/movable/screen/tutorial_timer = null

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

		src.tutorial_sidebar = create_screen("tutorial_sidebar", "Tutorial Sidebar", null, "", "NORTH-5, WEST+1", HUD_LAYER_3)
		src.tutorial_sidebar.maptext = ""
		src.tutorial_sidebar.maptext_width = 480
		src.tutorial_sidebar.maptext_x = 16
		src.tutorial_sidebar.maptext_y = -320
		src.tutorial_sidebar.maptext_height = 320
		src.tutorial_sidebar.plane = PLANE_HUD
		src.tutorial_sidebar.layer = 420

		src.tutorial_timer = create_screen("tutorial_timer", "Tutorial Timer", 'icons/mob/tutorial_ui.dmi', "", "NORTH-3, CENTER", HUD_LAYER_3)
		src.tutorial_timer.plane = PLANE_HUD
		src.tutorial_timer.alpha = 0 // proc below sets this to 255 when needed

	proc/update_step(new_text)
		src.tutorial_step.maptext = "<span class='c ol vga vt' style='background: #00000080;'>[new_text]</span>"

	proc/update_text(new_text)
		src.tutorial_text.maptext = "<span class='c ol vt' style='background: #00000080;'>[new_text]</span>"

	proc/update_sidebar(new_text)
		src.tutorial_sidebar.maptext = "<span class='vga ol vt' style='background: #00000080;'>[new_text]</span>"

	proc/flick_timer()
		src.tutorial_timer.alpha = 255
		FLICK("timer", src.tutorial_timer)

	proc/stop_timer()
		src.tutorial_timer.alpha = 0
