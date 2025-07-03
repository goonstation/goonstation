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
	can_burn = FALSE
	can_break = FALSE

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

/turf/simulated/floor/shuttle/yellow
	icon_state = "floor2"

/turf/simulated/floor/shuttle/white
	icon_state = "floor3"

/turf/simulated/floor/shuttle/red
	icon_state = "floor4"

/turf/simulated/floor/shuttle/purple
	icon_state = "floor5"

/turf/simulated/floor/shuttle/green
	icon_state = "floor6"

/turf/unsimulated/floor/shuttle
	name = "shuttle floor"
	icon_state = "floor"
	icon = 'icons/turf/shuttle.dmi'
	turf_flags = MOB_STEP
	can_burn = FALSE
	can_break = FALSE

/turf/unsimulated/floor/shuttle/yellow
	icon_state = "floor2"

/turf/unsimulated/floor/shuttle/white
	icon_state = "floor3"

/turf/unsimulated/floor/shuttle/red
	icon_state = "floor4"

/turf/unsimulated/floor/shuttle/purple
	icon_state = "floor5"

/turf/unsimulated/floor/shuttle/green
	icon_state = "floor6"

TYPEINFO(/turf/simulated/wall/auto/shuttle)
	connect_overlay = 1
	connect_across_areas = FALSE
TYPEINFO_NEW(/turf/simulated/wall/auto/shuttle)
	. = ..()
	// override parent so we can connect to ourselves
	connects_to_exceptions = list()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn, /turf/simulated/wall/auto/supernorn/wood,
		/turf/simulated/wall/false_wall, /obj/machinery/door, /obj/window, /obj/mapping_helper/wingrille_spawn,
		/turf/simulated/wall/auto/shuttle, /obj/indestructible/shuttle_corner
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/supernorn/wood, /turf/simulated/wall/false_wall/reinforced,
		/obj/machinery/door, /obj/window, /obj/mapping_helper/wingrille_spawn
	))
/turf/simulated/wall/auto/shuttle
	name = "shuttle wall"
	desc = "A shuttle wall. Pretty reinforced."
	icon = 'icons/turf/walls/shuttle/blue.dmi'
#ifdef PERSPECTIVE_EDITOR_WALL
	icon_state = "perspective-mapwall"
#else
	icon_state = "mapwall"
#endif
	light_mod = "wall-"
	opacity = 0
	flags = FLUID_DENSE | IS_PERSPECTIVE_FLUID

	attackby()
	attack_hand()
	hitby()
		. = ..()
	burn_down()
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

/obj/indestructible
	anchored = ANCHORED_ALWAYS

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
	icon = 'icons/turf/walls/shuttle/corner.dmi'
	icon_state = "corner"
	density = 1
	opacity = 0
	gas_impermeable = TRUE
	layer = EFFECTS_LAYER_BASE - 1
	flags = FLUID_DENSE | IS_PERSPECTIVE_FLUID

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
