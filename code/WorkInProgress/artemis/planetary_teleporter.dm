/obj/lrteleporter/planetary_teleporter
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
			for(var/obj/background_star/galactic_object/G in my_ship.my_galactic_objects)
				if(G.has_ship_body)
					if(G.my_ship_body)
						if(G.my_ship_body.landing_zone)
							found = 1
							link_html += {"[G.my_ship_body.destination_name] <a href='?src=\ref[src];send=\ref[G.my_ship_body.landing_zone]'><small>(Send)</small></a> <a href='?src=\ref[src];recieve=\ref[G.my_ship_body.landing_zone]'><small>(Recieve)</small></a><br>"}
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
		user << browse(html, "window=lrporter;size=250x380;can_resize=0;can_minimize=0;can_close=1")
		onclose(user, "lrporter", src)

	Topic(href, href_list)
		if(busy) return
		if(get_dist(usr, src) > 1 || usr.z != src.z) return

		if(href_list["send"])
			var/obj/landmark/destination_landmark/L = locate(href_list["send"])
			var/turf/target = locate(L.x, L.y, L.z)
			if(target)
				busy = 1
				flick("lrport1", src)
				playsound(src, 'sound/machines/lrteleport.ogg', 60, 1)
				playsound(target, 'sound/machines/lrteleport.ogg', 60, 1)
				for(var/atom/movable/M in src.loc)
					if(M.anchored) continue
					animate_teleport(M)
					SPAWN_DBG(0.6 SECONDS)
						M.set_loc(target)
				var/obj/decal/teleport_swirl/S = new/obj/decal/teleport_swirl(target)
				SPAWN_DBG(1 SECOND)
					busy = 0
					qdel(S)

		if(href_list["recieve"])
			var/obj/landmark/destination_landmark/L = locate(href_list["recieve"])
			var/turf/target = locate(L.x, L.y, L.z)
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
	var/obj/lrteleporter/planetary_teleporter/my_teleporter = null
	var/busy = 0

	New()
		..()
		SPAWN_DBG(1 SECOND)
			for(var/obj/lrteleporter/planetary_teleporter/P in world)
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
						if(G.my_ship_body.landing_zone)
							found = 1
							link_html += {"[G.my_ship_body.destination_name] <a href='?src=\ref[src];recieve=\ref[G.my_ship_body.landing_zone]'><small>(Receive)</small></a><br>"}
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
		user << browse(html, "window=lrporter;size=250x380;can_resize=0;can_minimize=0;can_close=1")
		onclose(user, "lrporter", my_teleporter)

	Topic(href, href_list)
		if(busy) return
		if(get_dist(usr, src) != 0) return

		if(href_list["recieve"])
			var/obj/landmark/destination_landmark/L = locate(href_list["recieve"])
			var/turf/target = locate(L.x, L.y, L.z)
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
