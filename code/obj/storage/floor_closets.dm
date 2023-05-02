
/obj/storage/closet/syndi
	name = "floor"
	desc = "Something weird about this thing."
	icon_state = "closedf"
	icon_closed = "closedf"
	density = 0
	soundproofing = 15
	p_class = 1
	plane = PLANE_DEFAULT


	close()
		var/turf/T = get_turf(src)
		if (T)
			src.icon = T.icon
			src.icon_closed = T.icon_state
			src.desc = T.desc + " It looks odd."
			src.plane = T.plane
		else
			src.icon = 'icons/obj/large_storage.dmi'
			src.icon_closed = "closedf"
		..()
		return

	open(entanglelogic, mob/user)
		if (src.welded)
			return
		src.icon = 'icons/obj/large_storage.dmi'
		src.plane = initial(src.plane)
		..()
		return

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

