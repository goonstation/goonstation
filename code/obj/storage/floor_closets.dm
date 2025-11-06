
/obj/storage/closet/syndi
	name = "floor"
	desc = "Something weird about this thing."
	icon_state = "closedf"
	icon_closed = "closedf"
	density = 0
	soundproofing = 15
	p_class = 1
	plane = PLANE_DEFAULT

	New()
		..()
		src.UpdateIcon()

	close(entanglelogic, mob/user)
		..()
		if (user)
			logTheThing(LOG_STATION, user, " closed a syndicate floor closet at [log_loc(src)]")
		src.UpdateIcon()

	open(entanglelogic, mob/user)
		if (src.welded)
			return
		..()
		if (user)
			logTheThing(LOG_STATION, user, " opened a syndicate floor closet at [log_loc(src)]")
		src.UpdateIcon()

	update_icon(turf/turf_override = null)
		. = ..()
		if (src.open)
			src.name = "closet"
			src.icon = 'icons/obj/large_storage.dmi'
			src.plane = initial(src.plane)
			src.desc = initial(src.desc)
			src.set_icon_state(src.icon_opened)
		else
			var/turf/T = turf_override || get_turf(src)
			if (T && T.plane == PLANE_FLOOR)
				src.name = T.name
				src.icon = T.icon
				src.icon_closed = T.icon_state
				src.set_icon_state(src.icon_closed)
				src.desc = T.desc + " It looks odd."
				src.plane = T.plane
				src.set_dir(T.dir)
			else
				src.name = "steel floor"
				src.icon = 'icons/obj/large_storage.dmi'
				src.icon_closed = "closedf"
				src.desc = "This is a floor.<br>It is made of steel. It looks odd."
				src.set_icon_state(src.icon_closed)
				src.plane = PLANE_FLOOR

	Move(NewLoc, direct)
		. = ..()
		src.UpdateIcon()

	set_loc(newloc)
		. = ..()
		src.UpdateIcon()

	recalcPClass()
		p_class = initial(p_class)

	Cross(atom/movable/mover)
		return 1

/obj/storage/closet/syndi/hidden
	anchored = ANCHORED
	New()
		..()
		var/turf/T = get_turf(src.loc)
		if (T)
			src.icon = T.icon
			src.icon_closed = T.icon_state
			src.icon_state = icon_closed
			src.name = T.name
			src.plane = T.plane
		else
			src.icon = 'icons/obj/large_storage.dmi'
			src.icon_closed = "closedf"

