#ifdef ENABLE_ARTEMIS

/obj/machinery/lrteleporter/planetary_teleporter
	name = "Planetary Teleporter"
	desc = "A pad used for teleportation to nearby bodies"
	var/ship_id = "artemis"
	var/obj/artemis/my_ship = null

	New()
		..()
		SPAWN(1 SECOND)
			for(var/obj/artemis/A in world)
				if(A.stars_id == src.ship_id)
					src.my_ship = A
					return

/obj/machinery/lrteleporter/planetary_teleporter/ui_data(mob/user)

	var/list/destinations = list()
	if(locate(/obj/background_star/galactic_object) in my_ship.my_galactic_objects)
		for(var/obj/background_star/galactic_object/G in src.my_ship.my_galactic_objects)
			if(G.has_ship_body)
				if(G.my_ship_body)
					if(G.my_ship_body.landing_zones)
						for(var/destination in G.my_ship_body.landing_zones )
							var/turf/T = G.my_ship_body.landing_zones[destination]
							destinations += list(list(
								"destination" = "[destination]",
								"ref" = "\ref[T]"))
	. = list(
		"destinations" = destinations
	)

/obj/machinery/lrteleporter/planetary_teleporter/ui_static_data(mob/user)
	. = list(
		"send_allowed" = TRUE,
		"receive_allowed" = TRUE,
		"syndicate" = (ship_id == "arjuna")
	)

/obj/machinery/lrteleporter/planetary_teleporter/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(busy) return

	switch(action)
		if("send")
			var/turf/target = locate(params["target"])
			if(target)
				busy = 1
				flick("lrport1", src)
				playsound(src, 'sound/machines/lrteleport.ogg', 60, TRUE)
				playsound(target, 'sound/machines/lrteleport.ogg', 60, TRUE)

				if(istype(target, /turf/simulated/wall))
					var/turf/simulated/wall/W = target
					W.dismantle_wall()

				for(var/atom/movable/M in src.loc)
					if(M.anchored) continue
					animate_teleport(M)
					SPAWN(0.6 SECONDS)
						M.set_loc(target)
				var/obj/decal/teleport_swirl/S = new/obj/decal/teleport_swirl(target)
				new/obj/decal/teleport_mark(target)
				SPAWN(1 SECOND)
					busy = 0
					qdel(S)

		if("receive")
			var/turf/target = locate(params["target"])
			if(target)
				busy = 1
				flick("lrport1", src)
				playsound(src, 'sound/machines/lrteleport.ogg', 60, TRUE)
				playsound(target, 'sound/machines/lrteleport.ogg', 60, TRUE)
				for(var/atom/movable/M in target)
					if(M.anchored) continue
					animate_teleport(M)
					SPAWN(0.6 SECONDS) M.set_loc(src.loc)
				var/obj/decal/teleport_swirl/S = new/obj/decal/teleport_swirl(target)
				SPAWN(1 SECOND)
					busy = 0
					qdel(S)


/obj/item/remote/planetary_teleporter
	name = "Planetary Teleporter Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "Triggers the Planetary Teleporter to Receive."
	icon_state = "locator"
	item_state = "electronic"
	density = 0
	anchored = 0
	w_class = W_CLASS_SMALL
	var/ship_id = "artemis"
	var/obj/machinery/lrteleporter/planetary_teleporter/my_teleporter = null
	var/busy = 0

	New()
		..()
		SPAWN(1 SECOND)
			for(var/obj/machinery/lrteleporter/planetary_teleporter/P in world)
				if(P.ship_id == src.ship_id)
					src.my_teleporter = P
					return

	attack_self(mob/user as mob)
		ui_interact(user)
		add_fingerprint(user)

/obj/item/remote/planetary_teleporter/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LongRangeTeleporter", name)
		ui.open()

/obj/item/remote/planetary_teleporter/ui_data(mob/user)
	var/list/destinations = list()
	if(locate(/obj/background_star/galactic_object) in my_teleporter.my_ship.my_galactic_objects)
		for(var/obj/background_star/galactic_object/G in my_teleporter.my_ship.my_galactic_objects)
			if(G.has_ship_body)
				if(G.my_ship_body)
					if(G.my_ship_body.landing_zones)
						for(var/destination in G.my_ship_body.landing_zones )
							var/turf/T = G.my_ship_body.landing_zones[destination]
							destinations += list(list(
								"destination" = "[destination]",
								"ref" = "\ref[T]"))
	. = list(
		"destinations" = destinations
	)

/obj/item/remote/planetary_teleporter/ui_static_data(mob/user)
	. = list(
		"send_allowed" = FALSE,
		"receive_allowed" = TRUE,
		"syndicate" = (my_teleporter.ship_id == "arjuna")
	)

/obj/item/remote/planetary_teleporter/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(busy) return

	if(action =="receive")
		var/turf/target = locate(params["target"])
		if(target)
			busy = 1
			flick("lrport1", my_teleporter)
			playsound(src, 'sound/machines/lrteleport.ogg', 60, TRUE)
			playsound(target, 'sound/machines/lrteleport.ogg', 60, TRUE)
			for(var/atom/movable/M in target)
				if(M.anchored) continue
				animate_teleport(M)
				SPAWN(0.6 SECONDS)
					M.set_loc(my_teleporter.loc)
			var/obj/decal/teleport_swirl/S = new/obj/decal/teleport_swirl(target)
			SPAWN(1 SECOND)
				busy = 0
				qdel(S)

#endif

obj/decal/teleport_mark
	icon = 'icons/misc/artemis/temps.dmi'
	icon_state = "decal_tele"
	name = "teleport mark"
	anchored = 1
	layer = FLOOR_EQUIP_LAYER1
	alpha = 180

	New(var/atom/location)
		..()
		for(var/obj/O in location)
			if(O == src) continue
			if(istype(O, /obj/decal/teleport_mark) || istype(O,/obj/machinery/lrteleporter) || istype(O,/obj/fakeobject/teleport_pad) )
				qdel(src)
				return
