/datum/hud/vision // generic overlays for modifying the mobs vision
	var/atom/movable/screen/hud/scan
	var/atom/movable/screen/hud/color_mod
	var/atom/movable/screen/hud/dither
	var/atom/movable/screen/hud/flash
	var/atom/movable/screen/hud/flash_dark

/datum/hud/vision/New()
	..()
	scan = create_screen("", "", 'icons/mob/hud_common.dmi', "scan", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_1)
	scan.mouse_opacity = 0
	scan.alpha = 0

	color_mod = create_screen("", "", 'icons/effects/white.dmi', "", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_2)
	color_mod.mouse_opacity = 0
	color_mod.plane = PLANE_MUL_OVERLAY_EFFECTS

	dither = create_screen("", "", 'icons/mob/hud_common.dmi', "dither_2", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_3)
	dither.mouse_opacity = 0
	dither.alpha = 0

	flash = create_screen("", "", 'icons/effects/white.dmi', "", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_3)
	flash.mouse_opacity = 0
	flash.alpha = 0

	flash_dark = create_screen("", "", 'icons/effects/white.dmi', "", "WEST, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_3)
	flash_dark.mouse_opacity = 0
	flash_dark.alpha = 0
	flash_dark.color = "#000000"

	remove_screen(scan)
	remove_screen(color_mod)
	remove_screen(dither)
	remove_screen(flash)
	remove_screen(flash_dark)

/datum/hud/vision/disposing()
	QDEL_NULL(scan)
	QDEL_NULL(color_mod)
	QDEL_NULL(dither)
	QDEL_NULL(flash)
	. = ..()

/datum/hud/vision/proc/flash(duration)
	if(flash)
		add_screen("flash")
		flash.alpha = 255
		flash_dark.alpha = 255
		animate(flash, alpha = 0, time = duration, easing = SINE_EASING)
		animate(flash_dark, alpha = 0, time = duration, easing = SINE_EASING)
		SPAWN(duration)
			remove_screen("flash")

/datum/hud/vision/proc/noise(duration)
	// hacky and incorrect but I didnt want to introduce another object just for this
	flash.icon_state = "noise"
	src.flash(duration)
	SPAWN(duration)
		flash.icon_state = "white"

/datum/hud/vision/proc/set_scan(scanline)
	if (scanline)
		add_screen(scan)
	else
		remove_screen(scan)
	scan.alpha = scanline ? 50 : 0

/datum/hud/vision/proc/set_color_mod(color)
	color_mod.color = color
	if (color == "#000000" || color == "#ffffff")
		remove_screen(color_mod)
	else
		add_screen(color_mod)

/datum/hud/vision/proc/animate_color_mod(color, duration)
	if(color_mod.color == color)
		return

	if (color == "#000000" || color == "#ffffff")
		remove_screen(color_mod)
	else
		add_screen(color_mod)

	animate(color_mod, color = color, time = duration)
	SPAWN(duration + 1)
		if (color == "#000000" || color == "#ffffff")
			remove_screen(color_mod)
		else
			add_screen(color_mod)

/datum/hud/vision/proc/set_dither_alpha(alpha)
	if (alpha > 0)
		add_screen(dither)
	else
		remove_screen(dither)
	dither.alpha = alpha

/datum/hud/vision/proc/animate_dither_alpha(alpha, duration)
	if(dither.alpha == alpha)
		return
	animate(dither, alpha = alpha, time = duration)
	SPAWN(duration + 1)
		if (alpha > 0)
			add_screen(dither)
		else
			remove_screen(dither)

/datum/hud/vision/add_screen(atom/movable/screen/S)
	if(S == "flash")
		if (!(flash in src.objects))
			src.objects += flash
			src.objects += flash_dark
			for (var/client/C in src.clients)
				if(C.dark_screenflash)
					C.screen += flash_dark
				else
					C.screen += flash
	else
		. = ..()

/datum/hud/vision/remove_screen(atom/movable/screen/S)
	if(S == "flash")
		if(src.objects)
			src.objects -= src.flash
			src.objects -= src.flash_dark
		for (var/client/C in src.clients)
			C.screen -= flash
			C.screen -= flash_dark
	. = ..()

