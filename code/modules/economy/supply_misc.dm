ABSTRACT_TYPE(/area/supply)
/area/supply
	expandable = FALSE

/area/supply/spawn_point //the area supplies are spawned at and fired from
	name = "supply spawn point"
	icon_state = "shuttle3"
	requires_power = 0

	#ifdef UNDERWATER_MAP
	color = OCEAN_COLOR
	#endif

/area/supply/delivery_point //the area supplies are fired at
	name = "supply target point"
	icon_state = "shuttle3"
	requires_power = 0

	#ifdef UNDERWATER_MAP
	color = OCEAN_COLOR
	#endif

/area/supply/sell_point //the area where supplies move from the station z level
	name = "supply sell region"
	icon_state = "shuttle3"
	requires_power = 0

	#ifdef UNDERWATER_MAP
	color = OCEAN_COLOR
	#endif

	Entered(var/atom/movable/AM)
		..()
		var/datum/artifact/art = null
		if(isobj(AM))
			var/obj/O = AM
			art = O.artifact
		if(art)
			shippingmarket.sell_artifact(AM, art)
		else if (istype(AM, /obj/storage/crate/biohazard/cdc))
			QM_CDC.receive_pathogen_samples(AM)
		else if (istype(AM, /obj/storage/crate) || istype(AM, /obj/storage/secure/crate/))
			if (AM.delivery_destination)
				for (var/datum/trader/T in shippingmarket.active_traders)
					if (T.crate_tag == AM.delivery_destination)
						shippingmarket.sell_crate(AM, T.goods_buy)
						return
			shippingmarket.sell_crate(AM)

/obj/plasticflaps //HOW DO YOU CALL THOSE THINGS ANYWAY
	name = "Plastic flaps"
	desc = "I definitely can't get past those. No way."
	icon = 'icons/obj/stationobjs.dmi' //Change this.
	icon_state = "plasticflaps"
	density = 0
	anchored = ANCHORED
	layer = EFFECTS_LAYER_UNDER_1
	event_handler_flags = USE_FLUID_ENTER
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WIRECUTTERS

	var/static/list/connects_to = typecacheof(list(
		/obj/machinery/door,
		/obj/window,
		/turf/simulated/wall/auto,
		/turf/unsimulated/wall/auto,
		/obj/plasticflaps
	))

/obj/plasticflaps/New()
	..()
	src.UpdateIcon()
	src.update_neighbors()

/obj/plasticflaps/update_icon()
	..()
	var/connectdir = get_connected_directions_bitflag(connects_to)
	if (connectdir & NORTH || connectdir & SOUTH)
		src.dir = EAST
		return
	if (connectdir & EAST || connectdir & WEST)
		src.dir = NORTH

/obj/plasticflaps/disposing()
	..()
	src.update_neighbors()

/obj/plasticflaps/proc/update_neighbors()
	for (var/turf/simulated/wall/auto/T in orange(1,src))
		T.UpdateIcon()
	for (var/obj/window/auto/O in orange(1,src))
		O.UpdateIcon()
	for (var/obj/grille/G in orange(1,src))
		G.UpdateIcon()

/obj/plasticflaps/Cross(atom/A)
	if (isliving(A)) // You Shall Not Pass!
		var/mob/living/M = A
		if (isghostdrone(M)) // except for drones
			return TRUE
		else if (istype(A,/mob/living/critter/changeling/handspider) || istype(A,/mob/living/critter/changeling/eyespider))
			return TRUE
		else if (isdead(M))
			return TRUE
		else if(!M.lying) // or you're lying down
			return FALSE
	return ..()

/obj/plasticflaps/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(50))
				qdel(src)
		if (3)
			if (prob(5))
				qdel(src)

/obj/marker/supplymarker
	icon_state = "X"
	icon = 'icons/misc/mark.dmi'
	name = "X"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	opacity = 0
