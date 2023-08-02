ABSTRACT_TYPE(/obj/mapping_helper/turfs)
/obj/mapping_helper/turfs
	layer = TURF_LAYER
	var/allow_space = FALSE
	var/turf/T

/obj/mapping_helper/turfs/setup()
	T = get_turf(src)
	if (!T)
		return
	if (istype(T, /turf/space) && !src.allow_space)
		return

/obj/mapping_helper/turfs/proc/do_on_turf()
	return

/** ===== Burner and breaker for floors =====
 * These may look out of place on non tiled flooring
 * use these instead of the scorched/burnt subtypes as they work for most floors
 * exceptions include shuttle floors, reinforced floors, planet auto floors, void tiles, etc
 * if placed on one of these floors it will be logged
 */

ABSTRACT_TYPE(/obj/mapping_helper/turfs/floor)
/obj/mapping_helper/turfs/floor
	name = "Floor Helper Parent"
	layer = DECAL_LAYER

/obj/mapping_helper/turfs/floor/setup()
	..()
	if (!istype(T, /turf/unsimulated/floor) && !istype(T, /turf/simulated/floor)) // This will throw some false ones for strangely pathed floors that should be floor subtypes
		logTheThing(LOG_DEBUG, src, "[src] placed on non floor turf [T.type] at [src.x], [src.y], [src.z].")
		return
	src.do_on_turf()

/obj/mapping_helper/turfs/floor/burner
	name = "Floor burner"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floorscorched1"

/obj/mapping_helper/turfs/floor/burner/do_on_turf()
	if (!T.can_burn)
		logTheThing(LOG_DEBUG, src, "[src] placed on unburnable floor [T.type] at [src.x], [src.y], [src.z].")
		return
	T.burn_tile()

/obj/mapping_helper/turfs/floor/damager
	name = "Floor damager"
	icon = 'icons/turf/floors.dmi'
	icon_state = "damaged1"

/obj/mapping_helper/turfs/floor/damager/do_on_turf()
	if (!T.can_break)
		logTheThing(LOG_DEBUG, src, "[src] placed on unbreakable floor [T.type] at [src.x], [src.y], [src.z].")
		return
	T.break_tile()
