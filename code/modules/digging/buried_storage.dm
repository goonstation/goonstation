/*
 * Copyright (C) 2025 Mr. Moriarty
 * Copyright (C) 2025 Firedhat
 *
 * Originally contributed to the 35 Below Project
 * Made available under the terms of the CC BY-NC-SA 3.0
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/atom/movable/buried_storage
	icon = null
	icon_state = null
	plane = PLANE_NOSHADOW_BELOW
	density = 0
	mouse_opacity = 0
	pass_unstable = FALSE

	var/turf/parent_turf
	var/has_buried_mob = FALSE
	var/number_of_objects = 0

	New(newLoc)
		. = ..()
		src.parent_turf = newLoc

	proc/move_turf_contents_to_storage()
		for (var/atom/movable/AM as anything in parent_turf)
			if (!istype(AM, /obj) && !istype(AM, /mob))
				continue
			if (!AM.mouse_opacity || istype(AM, /obj/decal) || istype(AM, /obj/effect) || istype(AM, /obj/effects))
				continue

			if (istype(AM, /mob))
				if (src.has_buried_mob)
					continue

				src.has_buried_mob = TRUE

			else
				if (src.number_of_objects >= 3)
					if (src.has_buried_mob)
						return

					continue

				else
					src.number_of_objects += 1

			AM.set_loc(src)

	proc/move_storage_contents_to_turf()
		for (var/atom/movable/AM as anything in src)
			AM.set_loc(parent_turf)

		src.has_buried_mob = FALSE
		src.number_of_objects = 0
