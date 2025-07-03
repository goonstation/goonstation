/image/foreground_parallax_occlusion_overlay
	icon = 'icons/misc/foreground_parallax_occlusion_overlay.dmi'
	icon_state = "overlay-0"
	plane = PLANE_FOREGROUND_PARALLAX_OCCLUSION

/obj/foreground_parallax_occlusion
	mouse_opacity = 0
	icon = 'icons/misc/foreground_parallax_occlusion_overlay.dmi'
	icon_state = "overlay-255"
	plane = PLANE_FOREGROUND_PARALLAX_OCCLUSION

/turf
	var/occlude_foreground_parallax_layers = FALSE
	var/fulltile_foreground_parallax_occlusion_overlay = FALSE

/turf/New()
	. = ..()
	var/area/A = get_area(src)
	if (A.occlude_foreground_parallax_layers)
		src.occlude_foreground_parallax_layers = TRUE

	if (src.occlude_foreground_parallax_layers)
		src.update_parallax_occlusion_overlay()

/turf/proc/update_parallax_occlusion_overlay(update_neighbors = TRUE)
	if (src.fulltile_foreground_parallax_occlusion_overlay)
		var/image/overlay = src.GetOverlayImage("foreground_parallax_occlusion_overlay") || new /image/foreground_parallax_occlusion_overlay
		overlay.icon_state = "overlay-255"
		src.AddOverlays(overlay, "foreground_parallax_occlusion_overlay")
		return

	var/connected_directions = 0

	// Cardinal
	for (var/dir in cardinal)
		var/turf/CT = get_step(src, dir)
		if (!CT?.occlude_foreground_parallax_layers)
			continue

		connected_directions |= dir
		if (update_neighbors)
			CT.update_parallax_occlusion_overlay(FALSE)

	// Ordinal
	for (var/i = 1 to 4)
		var/ordir = ordinal[i]
		if ((ordir & connected_directions) != ordir)
			continue

		var/turf/OT = get_step(src, ordir)
		if (!OT?.occlude_foreground_parallax_layers)
			continue

		connected_directions |= 8 << i
		if (update_neighbors)
			OT.update_parallax_occlusion_overlay(FALSE)

	var/image/overlay = src.GetOverlayImage("foreground_parallax_occlusion_overlay") || new /image/foreground_parallax_occlusion_overlay
	overlay.icon_state = "overlay-[connected_directions]"
	src.AddOverlays(overlay, "foreground_parallax_occlusion_overlay")

// Repugnant edge case handling, as some turfs will call `ClearAllOverlays()`, removing parallax occlusion overlays.
/turf/ClearAllOverlays()
	. = ..()

	if (src.occlude_foreground_parallax_layers)
		src.update_parallax_occlusion_overlay()

/// toggles foreground parallax occlusion for an area (and all turfs in the area) at runtime. For varediting and nothing else, really
/area/proc/_toggle_foreground_parallax_occlusion()
	if(src.occlude_foreground_parallax_layers)
		src.occlude_foreground_parallax_layers = FALSE
		for(var/turf/T in src)
			T.occlude_foreground_parallax_layers = FALSE
			T.ClearSpecificOverlays("foreground_parallax_occlusion_overlay")
	else
		src.occlude_foreground_parallax_layers = TRUE
		for(var/turf/T in src)
			T.occlude_foreground_parallax_layers = TRUE
			T.update_parallax_occlusion_overlay()
