/obj/mapping_helper/turfs
	layer = TURF_LAYER

/* ===== Burner and breaker for turfs =====
* These may look out of place on non tiled flooring
* use these instead of the scorched/burnt subtypes as they work for most floors
* exceptions include shuttle floors, reinforced floors, planet auto floors, void tiles, etc
* if placed on one of these floors it will be logged
*/

/obj/mapping_helper/turfs/burner
	name = "Floor burner"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floorscorched1"

	setup()
		var/turf/simulated/floor/T = src.loc
		if (istype(T, /turf/unsimulated/floor) || istype(T, /turf/simulated/floor))
			if (!T.can_burn)
				logTheThing(LOG_DEBUG, src, "[src] placed on unburnable floor at [src.x], [src.y], [src.z].")
			T.burn_tile()

/obj/mapping_helper/turfs/damager
	name = "Floor damager"
	icon = 'icons/turf/floors.dmi'
	icon_state = "damaged1"

	setup()
		var/turf/simulated/floor/T = src.loc
		if (istype(T, /turf/unsimulated/floor) || istype(T, /turf/simulated/floor))
			if (!T.can_break)
				logTheThing(LOG_DEBUG, src, "[src] placed on unbreakable floor at [src.x], [src.y], [src.z].")
			T.break_tile()
