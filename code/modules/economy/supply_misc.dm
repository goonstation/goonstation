ABSTRACT_TYPE(/area/supply)
/area/supply
	expandable = FALSE

/area/supply/spawn_point //the area supplies are spawned at and fired from
	name = "supply spawn point"
	icon_state = "shuttle3"
	requires_power = 0

	#ifdef UNDERWATER_MAP
	color = OCEAN_COLOR
	ambient_light = OCEAN_LIGHT
	#endif

/area/supply/delivery_point //the area supplies are fired at
	name = "supply target point"
	icon_state = "shuttle3"
	requires_power = 0

	#ifdef UNDERWATER_MAP
	color = OCEAN_COLOR
	ambient_light = OCEAN_LIGHT
	#endif

/area/supply/sell_point //the area where supplies move from the station z level
	name = "supply sell region"
	icon_state = "shuttle3"
	requires_power = 0

	#ifdef UNDERWATER_MAP
	color = OCEAN_COLOR
	ambient_light = OCEAN_LIGHT
	#endif

	Entered(var/atom/movable/AM)
		..()
		var/datum/artifact/art = null
		if(isobj(AM))
			var/obj/O = AM
			art = O.artifact
		if(art)
			shippingmarket.sell_artifact(AM, art)
		else if (istype(AM, /obj/storage/crate) || istype(AM, /obj/storage/secure/crate/))
			if (AM.delivery_destination)
				for (var/datum/trader/T in shippingmarket.active_traders)
					if (T.crate_tag == AM.delivery_destination)
						shippingmarket.sell_crate(AM, T.goods_buy)
						return
			shippingmarket.sell_crate(AM)

TYPEINFO(/obj/strip_door)
	mat_appearances_to_ignore = list("steel")
/obj/strip_door //HOW DO YOU CALL THOSE THINGS ANYWAY - Strip doors.
	name = "strip door frame"
	desc = "I definitely can't get past those. No way."
	icon = 'icons/obj/stationobjs.dmi' //Change this. - To what?
	icon_state = "strip_door_open"
	var/image/flap_icon = null
	density = 0
	anchored = ANCHORED
	layer = EFFECTS_LAYER_UNDER_1
	event_handler_flags = USE_FLUID_ENTER
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WIRECUTTERS
	material_amt = 0.1
	var/datum/material/flap_material = null
	var/flap_amount = 4 // just in case

	var/static/list/connects_to = typecacheof(list(
		/obj/machinery/door,
		/obj/window,
		/turf/simulated/wall/auto,
		/turf/unsimulated/wall/auto,
		/obj/strip_door
	))

	constructed
		New()
			..()
			src.reset_flaps()

	New()
		..()
		src.flap_material = new /datum/material/rubber/plastic()
		src.flap_icon = image(src.icon, "strip_door_flaps", -1)
		src.flap_icon.appearance_flags = RESET_COLOR | RESET_ALPHA
		src.set_flaps()
		src.update_neighbors()

	proc/set_flaps()
		src.name = "[src.flap_material.getName()] flaps"
		var/color = src.flap_material.getColor()
		if (color)
			src.flap_icon.color = color
		else
			src.flap_icon.color ="#333333"
		src.flap_icon.alpha = src.flap_material.getAlpha()
		src.underlays += src.flap_icon
		src.UpdateIcon()

	proc/reset_flaps()
		src.name = "strip door frame"
		src.flap_material = null
		src.icon_state = "strip_door_open"
		src.underlays = null
		src.UpdateIcon()

	update_icon()
		..()
		var/connectdir = get_connected_directions_bitflag(connects_to)
		if ((connectdir & NORTH) && (connectdir & SOUTH))
			src.dir = EAST
			return
		if ((connectdir & EAST) && (connectdir & WEST))
			src.dir = NORTH
			return
		if ((connectdir & NORTH) || (connectdir & SOUTH))
			src.dir = EAST
			return
		if ((connectdir & EAST) || (connectdir & WEST))
			src.dir = NORTH
			return

	proc/change_direction()
		if(src.dir == EAST)
			src.dir = NORTH
		else
			src.dir = EAST

	disposing()
		..()
		src.update_neighbors()

	proc/update_neighbors()
		for (var/turf/simulated/wall/auto/T in orange(1,src))
			T.UpdateIcon()
		for (var/obj/window/auto/O in orange(1,src))
			O.UpdateIcon()
		for (var/obj/mesh/M in orange(1,src))
			M.UpdateIcon()

	Cross(atom/A)
		if (!src.flap_material)  // You Shall Pass! But Only Because I Have No Flaps!
			return TRUE
		if(src.flap_material.hasTrigger(TRIGGERS_ON_ADD, /datum/materialProc/ethereal_add))
			return TRUE
		if (isliving(A)) // You Shall Not Pass!
			var/mob/living/M = A
			if (isghostdrone(M)) // except for drones
				return TRUE
			else if (isintangible(A))
				return TRUE
			else if (istype(A,/mob/living/critter/changeling/handspider) || istype(A,/mob/living/critter/changeling/eyespider))
				return TRUE
			else if (isdead(M))
				return TRUE
			else if(!M.lying) // or you're lying down
				return FALSE
		return ..()

	// Slow down of flaps dependant on density of material
	// The more dense, the more slowdown
	Crossed(atom/A)
		..()
		if (!src.flap_material)
			return
		if (isintangible(A))
			return
		if (isliving(A))
			var/mob/living/M = A
			var/density = src.flap_material.hasProperty("density") ? src.flap_material.getProperty("density") : 3
			M.changeStatus("slowed", 2 SECONDS, density * 2)
		src.flap_material.triggerOnEntered(src, A)

	// Ensure that we're no longer slowed when leaving flaps
	Uncrossed(atom/A)
		..()
		if (isliving(A))
			var/mob/living/M = A
			M.delStatus("slowed")

	ex_act(severity)
		switch(severity)
			if (1)
				qdel(src)
			if (2)
				if (prob(50))
					qdel(src)
			if (3)
				if (prob(5))
					qdel(src)

	attackby(obj/item/I, mob/user)
		if (ispryingtool(I))
			playsound(src.loc, 'sound/items/Crowbar.ogg', 30, 1, -2)
			src.change_direction()
		if(src.flap_material)
			if (issnippingtool(I))
				SETUP_GENERIC_ACTIONBAR(user, src, 1 SECOND, /obj/strip_door/proc/snip_flaps, user, I.icon, I.icon_state, null, INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)
		if (istype(I, /obj/item/sheet))
			if (I.amount >= src.flap_amount)
				SETUP_GENERIC_ACTIONBAR(user, src, 1 SECOND, /obj/strip_door/proc/insert_flaps, I, I.icon, I.icon_state, null, INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)
			else
				boutput(user, SPAN_NOTICE("You don't have enough material!"))
		..()

	proc/insert_flaps(obj/item/I)
		playsound(src.loc, 'sound/items/sticker.ogg', 30, 1, -2)
		src.flap_material = I.material
		I.change_stack_amount(-src.flap_amount)
		src.underlays = null
		src.set_flaps()

	proc/snip_flaps(mob/user)
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
		if (!src.flap_material)
			return
		var/obj/item/sheet/flaps = new /obj/item/sheet(user)
		flaps.amount = src.flap_amount
		flaps.setMaterial(src.flap_material)
		user.put_in_hand_or_drop(flaps)
		src.reset_flaps()

/obj/marker/supplymarker
	icon_state = "X"
	icon = 'icons/misc/mark.dmi'
	name = "X"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	opacity = 0
