// this is such a mess it gets its own HUD object
/datum/hud/vision_impair
	New()
		..()
		create_screen("", "", 'icons/mob/hud_common.dmi', "vimpair", "WEST, SOUTH to CENTER-3, NORTH", HUD_LAYER_UNDER_4, mouse_opacity = FALSE)
		create_screen("", "", 'icons/mob/hud_common.dmi', "vimpair", "CENTER+3, SOUTH to EAST, NORTH", HUD_LAYER_UNDER_4, mouse_opacity = FALSE)
		create_screen("", "", 'icons/mob/hud_common.dmi', "vimpair", "CENTER-2, CENTER+3 to CENTER+2, NORTH", HUD_LAYER_UNDER_4, mouse_opacity = FALSE)
		create_screen("", "", 'icons/mob/hud_common.dmi', "vimpair", "CENTER-2, SOUTH to CENTER+2, CENTER-3", HUD_LAYER_UNDER_4, mouse_opacity = FALSE)
