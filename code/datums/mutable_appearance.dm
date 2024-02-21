/*
 * okay yo mutable appearances should be used for non-directional dependent images instead of normal images for overlays and stuff
*/

//Note: These do not work for containers using fluid_image while equipped on your HUD currently for some reason.

//This is a helper proc similar to image() but it's for mutable appearances u dummy

/proc/mutable_appearance(icon, icon_state, layer = HUD_LAYER_UNDER_2, plane = FLOAT_PLANE)
	var/mutable_appearance/MA = new()
	MA.icon = icon
	MA.icon_state = icon_state
	MA.layer = layer
	MA.plane = plane
	return MA
