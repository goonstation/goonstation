/datum/hud/render_special //This entire file is a bodged-together hack and we should be ashamed
	var/atom/movable/screen/center_light
	var/center_light_scale = 1
	var/atom/movable/screen/lighting_darkness // makes it so stuff poking outside view() gets hidden / darkened
	var/atom/movable/screen/left_fill // hi it's cirr adding a hack to a hack
	var/atom/movable/screen/right_fill

/datum/hud/render_special/New()
	..()
	center_light = create_screen("", "", 'icons/effects/vision_default.dmi', "default", "CENTER-1, CENTER-1", LIGHTING_LAYER_BASE)
	center_light.mouse_opacity = 0 // this is really a giant hack and shouldn't be in the HUD system, but there aren't many good ways to handle this
	center_light.blend_mode = BLEND_ADD
	center_light.plane = PLANE_LIGHTING
	center_light.color = rgb(0.15 * 255, 0.15 * 255, 0.15 * 255)

	#ifdef UPSCALED_MAP
	center_light.Scale(3, 3)
	center_light.color = rgb(0.3 * 255, 0.3 * 255, 0.3 * 255)
	#endif

/datum/hud/render_special/disposing()
	QDEL_NULL(center_light)
	QDEL_NULL(lighting_darkness)
	QDEL_NULL(left_fill)
	QDEL_NULL(right_fill)
	. = ..()

/datum/hud/render_special/proc/set_centerlight_icon(state, color = rgb(0.15 * 255, 0.15 * 255, 0.15 * 255), blend_mode = BLEND_ADD, plane = PLANE_LIGHTING, wide = 0, alpha = 255)
	switch(state)
		if ("default")
			center_light.icon = 'icons/effects/vision_default.dmi'
			center_light.screen_loc = "CENTER-1, CENTER-1"
		if ("thermal")
			center_light.icon = 'icons/effects/vision_thermal.dmi'
			center_light.screen_loc = "CENTER-4.375, CENTER-4.375"
		if ("cateyes")
			center_light.icon = 'icons/effects/vision_cateyes.dmi'
			center_light.screen_loc = "CENTER-4.5, CENTER-4.5"
		else
			if (wide)
				center_light.icon = 'icons/effects/vision_wide.dmi'
				center_light.screen_loc = "CENTER-10, CENTER-7"
			else
				center_light.icon = 'icons/effects/vision.dmi'
				center_light.screen_loc = "CENTER-7, CENTER-7"

	center_light.icon_state = state
	center_light.color = color
	center_light.blend_mode = blend_mode
	center_light.plane = plane
	center_light.alpha = 255

// ♫♪ haaacks are aaaaall i'm maaaade ooofff ♪♫♪
/datum/hud/render_special/proc/set_widescreen_fill(var/color="#FFFFFF", var/plane=PLANE_LIGHTING, var/alpha=255)
	var/matrix/flip = matrix()
	flip.Scale(-1,1)

	if(isnull(left_fill))
		left_fill = create_screen("", "", 'icons/effects/overlays/solid.dmi', "solid", "LEFT-12,CENTER-7", LIGHTING_LAYER_BASE)
		left_fill.appearance_flags = TILE_BOUND | PIXEL_SCALE
		left_fill.mouse_opacity = 1 // this is meant to OBSCURE ok
		left_fill.transform = flip
	if(isnull(right_fill))
		right_fill = create_screen("", "", 'icons/effects/overlays/solid.dmi', "solid", "RIGHT+12,CENTER-7", LIGHTING_LAYER_BASE)
		right_fill.appearance_flags = TILE_BOUND | PIXEL_SCALE
		right_fill.mouse_opacity = 1
		right_fill.transform = flip

	left_fill.color = color
	left_fill.plane = plane
	left_fill.alpha = alpha
	right_fill.color = color
	right_fill.plane = plane
	right_fill.alpha = alpha
