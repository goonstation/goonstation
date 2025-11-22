/atom/movable/proc/should_drift()
	var/turf/T = src.loc
	var/area/A = get_area(src)
	return (istype(A) && A.has_gravity == FALSE) || (istype(T) && T.throw_unlimited) || src.no_gravity

/mob/should_drift()
	if (src.is_spacefaring())
		return FALSE
	if (src.anchored)
		return FALSE
	. = ..()

/obj/item/dummy/should_drift()
	return FALSE
