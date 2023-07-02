/obj/mapping_helper/turfs
	layer = TURF_LAYER

/* ===== Burner and breaker for turfs =====
* These may look out of place on non tiled flooring
* use these instead of the scorched/burnt subtypes as they work all floors excluding shuttle
*/

/obj/mapping_helper/turfs/burner
	icon = 'icons/turf/floors.dmi'
	icon_state = "floorscorched1"

	setup()
		var/turf/simulated/floor/T = src.loc
		if (istype(T, /turf/unsimulated/floor) || istype(T, /turf/simulated/floor))
			T.burn_tile()

/obj/mapping_helper/turfs/damager
	icon = 'icons/turf/floors.dmi'
	icon_state = "damaged1"

	setup()
		var/turf/simulated/floor/T = src.loc
		if (istype(T, /turf/unsimulated/floor) || istype(T, /turf/simulated/floor))
			T.break_tile()
