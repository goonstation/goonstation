/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=--=-=-=-SHUTTLE TURFS & OBJS, DUH!-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */


////////////////////////////////////////////////////////////////TURFS
/turf/simulated/shuttle
	name = "shuttle wall"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0
	explosion_resistance = 8

	attackby()
	attack_hand()
	hitby()
		. = ..()
	reagent_act()
	bullet_act()
	ex_act()
	blob_act()
	meteorhit()
	damage_heat()
	damage_corrosive()
	damage_piercing()
	damage_slashing()
	damage_blunt()

/turf/space/shuttle_transit
	icon_state = "tplaceholder"

	New()
		..()
		if (icon_state == "tplaceholder") icon_state = "near_blank"

/turf/space/shuttle_transit/safe
	temperature = T20C
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/simulated/floor/shuttle
	name = "shuttle floor"
	icon_state = "floor"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0
	turf_flags = MOB_STEP

	hitby()
		. = ..()
	reagent_act()
	bullet_act()
	ex_act()
	blob_act()
	meteorhit()
	damage_heat()
	damage_corrosive()
	damage_piercing()
	damage_slashing()
	damage_blunt()

/turf/unsimulated/floor/shuttle
	name = "shuttle floor"
	icon_state = "floor"
	icon = 'icons/turf/shuttle.dmi'
	turf_flags = MOB_STEP

	hitby()
		. = ..()
	reagent_act()
	bullet_act()
	ex_act()
	blob_act()
	meteorhit()
	damage_heat()
	damage_corrosive()
	damage_piercing()
	damage_slashing()
	damage_blunt()


TYPEINFO(/turf/simulated/wall/auto/shuttle)
	connect_overlay = 1
	connect_across_areas = FALSE
TYPEINFO_NEW(/turf/simulated/wall/auto/shuttle)
	. = ..()
	// override parent so we can connect to ourselves
	connects_to_exceptions = list()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn, /turf/simulated/wall/auto/supernorn/wood,
		/turf/simulated/wall/false_wall, /obj/machinery/door, /obj/window, /obj/wingrille_spawn,
		/turf/simulated/wall/auto/shuttle, /obj/indestructible/shuttle_corner
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/supernorn/wood, /turf/simulated/wall/false_wall/reinforced,
		/obj/machinery/door, /obj/window, /obj/wingrille_spawn
	))
/turf/simulated/wall/auto/shuttle
	name = "shuttle wall"
	desc = "A shuttle wall. Pretty reinforced."
	icon = 'icons/turf/walls_shuttle.dmi'
	light_mod = "wall-"
	opacity = 0
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID

	attackby()
	attack_hand()
	hitby()
		. = ..()
	reagent_act()
	bullet_act()
	ex_act()
	blob_act()
	meteorhit()
	damage_heat()
	damage_corrosive()
	damage_piercing()
	damage_slashing()
	damage_blunt()

// ---------------------------------------------- OBJECTS -------------------------------------

/obj/indestructible/
	anchored = 2

	attackby()
	attack_hand()
	hitby()
		. = ..()
	reagent_act()
	bullet_act()
	ex_act()
	blob_act()
	meteorhit()
	damage_heat()
	damage_corrosive()
	damage_piercing()
	damage_slashing()
	damage_blunt()

/// an invisible thing to stop people walking where they 'aint meant to.
/obj/indestructible/invisible_block
	density = 1
	mouse_opacity = 0

	examine()
		return list()


/obj/indestructible/invisible_block/opaque
	opacity = 1

	examine()
		return list()


/turf/simulated/shuttle/wall/cockpit
	name = "shuttle cockpit"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "shuttlecock"
	layer = EFFECTS_LAYER_BASE
	pixel_x = -64
	pixel_y = -64
	opacity = 0
	plane = PLANE_DEFAULT

/turf/simulated/shuttle/wall/cockpit/window
	name = "shuttle wall"
	icon_state = "wall1"
	icon = 'icons/turf/shuttle.dmi'
	opacity = 0
	pixel_x = 0
	pixel_y = 0
	layer = TURF_LAYER

/obj/indestructible/shuttle_corner
	plane = PLANE_WALL
	name = "shuttle wall"
	desc = "A shuttle wall. Pretty reinforced. This appears to be a corner."
	icon = 'icons/turf/walls_shuttle.dmi'
	icon_state = "corner"
	density = 1
	opacity = 0
	layer = EFFECTS_LAYER_BASE - 1
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID

	set_loc(newloc) // fancy shuttle turf changing bullshit GO
		if (!newloc) return
		var/turf/oldArea = get_area(src)
		. = ..()
		var/area/newArea = get_area(newloc)
		var/turf/T = get_turf(newloc)
		if (newArea == oldArea || !istype(newArea,/area/shuttle)) return
		if (!T) return
		if (istype(T,/turf/unsimulated/floor/shuttle) || istype(T,/turf/simulated/floor))
			return

		// some other code handles turning this into the correct stuff
		T.ReplaceWithSpaceForce()
		T.fullbright = 0

//TODO: CLEAN UP
/turf/simulated/shuttle/wall
	name = "shuttle wall"
	icon_state = "wall"
	var/icon_style = "wall"
	opacity = 1
	density = 1
	gas_impermeable = 1
	pathable = 0

	New()
		..()
		SPAWN(6 SECONDS) // patch up some ugly corners in derelict mode
			if (derelict_mode)
				if (src.icon_state == "[src.icon_style]_space")
					src.icon_state = "[src.icon_style]_void"
		return

/turf/simulated/shuttle/wall/escape
	opacity = 0

/turf/simulated/shuttle/wall/corner
	icon_state = "wall_space"
	opacity = 0
//END TODO
