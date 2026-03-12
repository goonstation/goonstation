ABSTRACT_TYPE(/obj/mapping_helper/turf)
/obj/mapping_helper/turf
	name = "turf helper parent"
	layer = TURF_LAYER
	var/allow_space = FALSE
	var/turf/T

/obj/mapping_helper/turf/setup()
	T = get_turf(src)
	if (!T)
		return TRUE
	if (!src.allow_space)
		if (istype(T, /turf/space))
			logTheThing(LOG_DEBUG, src, "[identify_object(src)] which is disallowed from space placed on [identify_object(T)] at [src.x], [src.y], [src.z].")
			return TRUE

/obj/mapping_helper/turf/proc/do_on_turf()
	return

/obj/mapping_helper/turf/disposing()
	T = null
	..()

/** ===== Burner and breaker for floors =====
 * These may look out of place on non tiled flooring
 * use these instead of the scorched/burnt subtypes as they work for most floors
 * exceptions are floors that have can break/burn set to FALSE
 * includes shuttle floors, reinforced floors, planet auto floors, void tiles, etc
 * if placed on one of these floors it will be logged
 */

ABSTRACT_TYPE(/obj/mapping_helper/turf/floor)
/obj/mapping_helper/turf/floor
	name = "floor helper parent"
	layer = DECAL_LAYER

/obj/mapping_helper/turf/floor/setup()
	if (..())
		return
	if (!istype(T, /turf/unsimulated/floor) && !istype(T, /turf/simulated/floor)) // This will throw some false ones for strangely pathed floors that should be floor subtypes
		logTheThing(LOG_DEBUG, src, "[identify_object(src)] placed on non floor turf [identify_object(T)] at [src.x], [src.y], [src.z].")
		return
	src.do_on_turf()

/obj/mapping_helper/turf/floor/burner
	name = "floor burner"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floorscorched1"

/obj/mapping_helper/turf/floor/burner/do_on_turf()
	if (!T.can_burn)
		logTheThing(LOG_DEBUG, src, "[identify_object(src)] placed on unburnable floor [identify_object(T)] at [src.x], [src.y], [src.z].")
		return
	T.burn_tile()

/obj/mapping_helper/turf/floor/damager
	name = "floor damager"
	icon = 'icons/turf/floors.dmi'
	icon_state = "damaged1"

/obj/mapping_helper/turf/floor/damager/do_on_turf()
	if (!T.can_break)
		logTheThing(LOG_DEBUG, src, "[identify_object(src)] placed on unbreakable floor [identify_object(T)] at [src.x], [src.y], [src.z].")
		return
	T.break_tile()

/obj/mapping_helper/turf/floor/darkener
	name = "floor fade to black"
	icon_state = "darkener"

/obj/mapping_helper/turf/floor/darkener/do_on_turf()
	T.opacity = TRUE
	var/mutable_appearance/overlay = image('icons/effects/mapeditor.dmi', "darkener", dir=src.dir)
	T.AddOverlays(overlay, "darkener")
