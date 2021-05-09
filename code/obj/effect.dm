/obj/effect/distort
	name = "distort effect"
	icon = 'icons/effects/distort.dmi'
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_ID

	New()
		..()
		src.render_target = "*\ref[src]"
