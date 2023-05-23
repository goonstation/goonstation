/atom/movable/overlay/foreground_parallax_occlusion_overlay
	icon = 'icons/misc/foreground_parallax_occlusion_overlay.dmi'
	icon_state = "overlay-0"
	plane = PLANE_FOREGROUND_PARALLAX_OCCLUSION

	New()
		. = ..()
		src.update_overlay()

	proc/update_overlay(update_neighbors = TRUE)
		var/connected_directions = 0
		// Cardinal
		for (var/dir in cardinal)
			var/turf/CT = get_step(src, dir)
			for (var/atom/movable/overlay/foreground_parallax_occlusion_overlay/overlay in CT)
				connected_directions |= dir
				if (update_neighbors)
					overlay.update_overlay(FALSE)
				break

		// Ordinal
		for (var/i = 1 to 4)
			var/ordir = ordinal[i]
			if ((ordir & connected_directions) != ordir)
				continue
			var/turf/OT = get_step(src, ordir)
			for (var/atom/movable/overlay/foreground_parallax_occlusion_overlay/overlay in OT)
				connected_directions |= 8 << i
				if (update_neighbors)
					overlay.update_overlay(FALSE)
				break

		src.icon_state = "overlay-[connected_directions]"


/turf/New()
	. = ..()
	var/area/A = get_area(src)
	if (A.occlude_foreground_parallax_layers)
		new /atom/movable/overlay/foreground_parallax_occlusion_overlay(src)
