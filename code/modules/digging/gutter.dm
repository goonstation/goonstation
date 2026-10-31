#define GUTTER_LIGHTING_LEVEL 45

/turf/unsimulated/floor/auto/trench/gutter
	intact = FALSE
	can_fill = FALSE
	step_material = "step_lattice"
	base_icon_state = "gutter" // sprite adapted from 35below reinforced walls

	edge_overlays()
		return

/turf/unsimulated/floor/auto/trench/gutter/underlit

	var/static/image/starlight

/turf/unsimulated/floor/auto/trench/gutter/underlit/New()
	. = ..()

	// i copied this for gutter lighting im sory
	// // forbidden zone // //
	src.update_icon() // HIGHLY ILLEGAL NEVER DO THIS, SPECIAL CASE IGNORE ME (for starlight)
	// // do not pass go // //

/turf/unsimulated/floor/auto/trench/gutter/underlit/update_icon(starlight_alpha=GUTTER_LIGHTING_LEVEL, starlight_color_override=null)

	// underlays are checked in CI for duplicate turfs on a dmm tile
	#ifndef CI_RUNTIME_CHECKING
	if(!starlight)
		starlight = mutable_appearance('icons/effects/overlays/simplelight.dmi', "medium_center")
		starlight.pixel_x = -32
		starlight.pixel_y = -32
		starlight.appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR | KEEP_APART // PIXEL_SCALE omitted intentionally
		starlight.layer = LIGHTING_LAYER_BASE
		starlight.plane = PLANE_LIGHTING
		starlight.blend_mode = BLEND_ADD

	if(!isnull(starlight_alpha))
		starlight.alpha = starlight_alpha
	starlight.color = starlight_color_override ? starlight_color_override : "#5f2300"

	if(length(src.underlays))
		src.underlays = list(starlight)
	else
		src.underlays += starlight
	#endif

#undef GUTTER_LIGHTING_LEVEL
