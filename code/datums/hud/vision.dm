/datum/hud/vision // generic overlays for modifying the mobs vision
	var/atom/movable/screen/hud
		scan
		color_mod
		dither
		flash

	New()
		..()
		scan = create_screen("", "", 'icons/mob/hud_common.dmi', "scan", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_1)
		scan.mouse_opacity = 0
		scan.alpha = 0

		color_mod = create_screen("", "", 'icons/effects/white.dmi', "", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_2)
		color_mod.mouse_opacity = 0
		color_mod.blend_mode = BLEND_MULTIPLY
		color_mod.plane = PLANE_OVERLAY_EFFECTS

		dither = create_screen("", "", 'icons/mob/hud_common.dmi', "dither_2", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_3)
		dither.mouse_opacity = 0
		dither.alpha = 0

		flash = create_screen("", "", 'icons/effects/white.dmi', "", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_3)
		flash.mouse_opacity = 0
		flash.alpha = 0

		remove_screen(scan)
		remove_screen(color_mod)
		remove_screen(dither)
		remove_screen(flash)

	proc
		flash(duration)
			if(flash)
				add_screen(flash)
				flash.alpha = 255
				animate(flash, alpha = 0, time = duration, easing = SINE_EASING)
				SPAWN(duration)
					remove_screen(flash)

		noise(duration)
			// hacky and incorrect but I didnt want to introduce another object just for this
			flash.icon_state = "noise"
			src.flash(duration)
			SPAWN(duration)
				flash.icon_state = "white"

		set_scan(scanline)
			if (scanline)
				add_screen(scan)
			else
				remove_screen(scan)
			scan.alpha = scanline ? 50 : 0

		set_color_mod(color)
			color_mod.color = color
			if (color == "#000000" || color == "#ffffff")
				remove_screen(color_mod)
			else
				add_screen(color_mod)
				color_mod.plane = PLANE_OVERLAY_EFFECTS-1

		animate_color_mod(color, duration)
			if(color_mod.color == color)
				return

			if (color == "#000000" || color == "#ffffff")
				remove_screen(color_mod)
			else
				add_screen(color_mod)
				color_mod.plane = PLANE_OVERLAY_EFFECTS-1 //otherwise it doesnt draw. i dont know why.

			animate(color_mod, color = color, time = duration)
			SPAWN(duration + 1)
				if (color == "#000000" || color == "#ffffff")
					remove_screen(color_mod)
				else
					add_screen(color_mod)
					color_mod.plane = PLANE_OVERLAY_EFFECTS-1 //otherwise it doesnt draw. i dont know why.

		set_dither_alpha(alpha)
			if (alpha > 0)
				add_screen(dither)
			else
				remove_screen(dither)
			dither.alpha = alpha

		animate_dither_alpha(alpha, duration)
			if(dither.alpha == alpha)
				return
			animate(dither, alpha = alpha, time = duration)
			SPAWN(duration + 1)
				if (alpha > 0)
					add_screen(dither)
				else
					remove_screen(dither)


