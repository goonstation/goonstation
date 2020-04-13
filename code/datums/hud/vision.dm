/datum/hud/vision // generic overlays for modifying the mobs vision
	var/obj/screen/hud
		scan
		color_mod
		color_mod_floor //hi it's ZeWaka adding a hack to a hack
		dither
		flash

	New()
		scan = create_screen("", "", 'icons/mob/hud_common.dmi', "scan", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_1)
		scan.mouse_opacity = 0
		scan.alpha = 0

		color_mod = create_screen("", "", 'icons/effects/white.dmi', "", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_2)
		color_mod.mouse_opacity = 0
		color_mod.blend_mode = BLEND_MULTIPLY
		color_mod.plane = PLANE_DEFAULT // hack for now since the HUD plane can't multiply together with colors on other planes
		color_mod_floor = create_screen("", "", 'icons/effects/white.dmi', "", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_2) //Do you enjoy hacks? I do too!
		color_mod_floor.mouse_opacity = 0
		color_mod_floor.blend_mode = BLEND_MULTIPLY
		color_mod_floor.plane = PLANE_FLOOR // hack

		dither = create_screen("", "", 'icons/mob/hud_common.dmi', "dither_2", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_3)
		dither.mouse_opacity = 0
		dither.alpha = 0

		flash = create_screen("", "", 'icons/effects/white.dmi', "", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_3)
		flash.mouse_opacity = 0
		flash.alpha = 0

		remove_screen(scan)
		remove_screen(color_mod)
		remove_screen(color_mod_floor)
		remove_screen(dither)
		remove_screen(flash)

	proc
		flash(duration)
			if(flash)
				add_screen(flash)
				flash.alpha = 255
				animate(flash, alpha = 0, time = duration, easing = SINE_EASING)
				SPAWN_DBG(duration)
					remove_screen(flash)

		noise(duration)
			// hacky and incorrect but I didnt want to introduce another object just for this
			flash.icon_state = "noise"
			src.flash(duration)
			SPAWN_DBG(duration)
				flash.icon_state = "white"

		set_scan(scanline)
			if (scanline)
				add_screen(scan)
			else
				remove_screen(scan)
			scan.alpha = scanline ? 50 : 0

		set_color_mod(color)
			color_mod.color = color
			color_mod_floor.color = color
			if (color == "#000000")
				remove_screen(color_mod)
				remove_screen(color_mod_floor)
			else
				add_screen(color_mod)
				add_screen(color_mod_floor)

		animate_color_mod(color, duration)
			animate(color_mod, color = color, time = duration)
			animate(color_mod_floor, color = color, time = duration)
			SPAWN_DBG(duration + 1)
				if (color == "#000000")
					remove_screen(color)
					remove_screen(color_mod_floor)
				else
					add_screen(color)
					add_screen(color_mod_floor)

		set_dither_alpha(alpha)
			if (alpha > 0)
				add_screen(dither)
			else
				remove_screen(dither)
			dither.alpha = alpha

		animate_dither_alpha(alpha, duration)
			animate(dither, alpha = alpha, time = duration)
			SPAWN_DBG(duration + 1)
				if (alpha > 0)
					add_screen(dither)
				else
					remove_screen(dither)


