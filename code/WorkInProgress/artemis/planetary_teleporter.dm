#ifdef ENABLE_ARTEMIS

/obj/machinery/lrteleporter/planetary_teleporter
	name = "Planetary Teleporter"
	desc = "A pad used for teleportation to nearby bodies"
	var/ship_id = "artemis"
	var/obj/artemis/my_ship = null

	New()
		..()
		SPAWN_DBG(1 SECOND)
			for(var/obj/artemis/A in world)
				if(A.stars_id == src.ship_id)
					src.my_ship = A
					return

	attack_hand(mob/user as mob)
		var/link_html = "<br>"
		var/found = 0

		if(locate(/obj/background_star/galactic_object) in my_ship.my_galactic_objects)
			for(var/obj/background_star/galactic_object/G in src.my_ship.my_galactic_objects)
				if(G.has_ship_body)
					if(G.my_ship_body)
						if(G.my_ship_body.landing_zones)
							found = 1
							for(var/destination in G.my_ship_body.landing_zones )
								var/turf/T = G.my_ship_body.landing_zones[destination]
								link_html += {"[destination] <a href='?src=\ref[src];send=\ref[T]'><small>(Send)</small></a> <a href='?src=\ref[src];receive=\ref[T]'><small>(Receive)</small></a><br>"}
		if(!found)
			link_html = "<br>No co-ordinates available.<br>"

		var/html = {"<!doctype html>
			<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
			<html>
			<head>
			<title>Planetary teleporter</title>
			</head>
			<body style="overflow:auto;background-color: #eeeeee;">
			<p>Long-range destinations:</p><br>
			[link_html]
			</body>
			"}

		src.add_dialog(user)
		add_fingerprint(user)
		user << browse(html, "window=planetporter;size=250x380;can_resize=0;can_minimize=0;can_close=1")
		onclose(user, "planetporter", src)

	Topic(href, href_list)
		if(busy) return
		if(get_dist(usr, src) > 1 || usr.z != src.z) return

		if(href_list["send"])
			var/turf/target = locate(href_list["send"])
			if(target)
				busy = 1
				flick("lrport1", src)
				playsound(src, 'sound/machines/lrteleport.ogg', 60, 1)
				playsound(target, 'sound/machines/lrteleport.ogg', 60, 1)

				if(istype(target, /turf/simulated/wall))
					var/turf/simulated/wall/W = target
					W.dismantle_wall()

				for(var/atom/movable/M in src.loc)
					if(M.anchored) continue
					animate_teleport(M)
					SPAWN_DBG(0.6 SECONDS)
						M.set_loc(target)
				var/obj/decal/teleport_swirl/S = new/obj/decal/teleport_swirl(target)
				new/obj/decal/teleport_mark(target)
				SPAWN_DBG(1 SECOND)
					busy = 0
					qdel(S)

		if(href_list["receive"])
			var/turf/target = locate(href_list["receive"])
			if(target)
				busy = 1
				flick("lrport1", src)
				playsound(src, 'sound/machines/lrteleport.ogg', 60, 1)
				playsound(target, 'sound/machines/lrteleport.ogg', 60, 1)
				for(var/atom/movable/M in target)
					if(M.anchored) continue
					animate_teleport(M)
					SPAWN_DBG(0.6 SECONDS) M.set_loc(src.loc)
				var/obj/decal/teleport_swirl/S = new/obj/decal/teleport_swirl(target)
				SPAWN_DBG(1 SECOND)
					busy = 0
					qdel(S)

/obj/item/remote/planetary_teleporter
	name = "Planetary Teleporter Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "Triggers the Planetary Teleporter to Receive."
	icon_state = "locator"
	item_state = "electronic"
	density = 0
	anchored = 0.0
	w_class = W_CLASS_SMALL
	var/ship_id = "artemis"
	var/obj/machinery/lrteleporter/planetary_teleporter/my_teleporter = null
	var/busy = 0

	New()
		..()
		SPAWN_DBG(1 SECOND)
			for(var/obj/machinery/lrteleporter/planetary_teleporter/P in world)
				if(P.ship_id == src.ship_id)
					src.my_teleporter = P
					return

	attack_self(mob/user as mob)

		var/link_html = "<br>"
		var/found = 0

		if(locate(/obj/background_star/galactic_object) in my_teleporter.my_ship.my_galactic_objects)
			for(var/obj/background_star/galactic_object/G in my_teleporter.my_ship.my_galactic_objects)
				if(G.has_ship_body)
					if(G.my_ship_body)
						if(G.my_ship_body.landing_zones)
							found = 1
							for(var/destination in G.my_ship_body.landing_zones )
								var/turf/T = G.my_ship_body.landing_zones[destination]
								link_html += {"[destination] <a href='?src=\ref[src];receive=\ref[T]'><small>(Receive)</small></a><br>"}
		if(!found)
			link_html = "<br>No co-ordinates available.<br>"

		var/html = {"<!doctype html>
			<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
			<html>
			<head>
			<title>Planetary teleporter</title>
			</head>
			<body style="overflow:auto;background-color: #eeeeee;">
			<p>Long-range destinations:</p><br>
			[link_html]
			</body>
			"}

		my_teleporter.add_dialog(user)
		add_fingerprint(user)
		user << browse(html, "window=rmt_planet_porter;size=250x380;can_resize=0;can_minimize=0;can_close=1")
		onclose(user, "rmt_planet_porter", my_teleporter)

	Topic(href, href_list)
		if(busy) return
		if(get_dist(usr, src) != 0) return

		if(href_list["receive"])
			var/turf/target = locate(href_list["receive"])
			if(target)
				busy = 1
				flick("lrport1", my_teleporter)
				playsound(my_teleporter, 'sound/machines/lrteleport.ogg', 60, 1)
				for(var/atom/movable/M in target)
					if(M.anchored) continue
					animate_teleport(M)
					if(ismob(M))
						var/mob/O = M
						O.changeStatus("stunned",20) // 2 seconds
					SPAWN_DBG(0.6 SECONDS) M.set_loc(my_teleporter.loc)
				var/obj/decal/teleport_swirl/S = new/obj/decal/teleport_swirl(target)
				SPAWN_DBG(1 SECOND)
					busy = 0
					qdel(S)


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
			if(istype(O, /obj/decal/teleport_mark) || istype(O,/obj/lrteleporter) || istype(O,/obj/decal/fakeobjects/teleport_pad) )
				qdel(src)
				return

#endif
