/atom/movable/proc/should_drift()
	var/turf/T = src.loc
	var/area/A = get_area(src)
	return istype(T, /turf/space) || (istype(T) && T.throw_unlimited) || src.no_gravity || !A?.has_gravity

/mob/should_drift()
	if (src.is_spacefaring())
		return FALSE
	. = ..()

/obj/item/dummy/should_drift()
	return FALSE
