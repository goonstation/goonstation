/*
 * Copyright (C) 2025 Mr. Moriarty
 * Copyright (C) 2010,2016,2020-2025 Goonstation Contributors
 *
 * Contributed to the 35 Below Project, derived at least 4.5%
 * from code in Goonstation available through the terms of the
 * CreativeCommons BY-NC-SA 3.0 United States License ONLY.
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/atom/movable/screen/ambient_lighting
	icon = 'icons/effects/ambient.dmi'
	icon_state = "ambient_light"
	plane = PLANE_AMBIENT_LIGHTING
	appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_ALPHA | RESET_COLOR
	screen_loc = "1,1"


/atom/movable/screen/ambient_lighting/proc/animate_day_night()
	return

/atom/movable/screen/ambient_lighting/proc/set_midday()
	return

/atom/movable/screen/ambient_lighting/proc/set_midnight()
	return

/atom/movable/screen/ambient_lighting/proc/animate_from_dawn()
	return

/atom/movable/screen/ambient_lighting/proc/animate_from_dusk()
	return
