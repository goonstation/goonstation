//Floorbot assemblies
/obj/item/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top"
	name = "tiles and toolbox"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "toolbox_tiles"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = TABLEPASS

/obj/item/toolbox_tiles_sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached"
	name = "tiles, toolbox and sensor arrangement"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "toolbox_tiles_sensor"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = TABLEPASS

//Floorbot
/obj/machinery/bot/floorbot
	name = "Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "floorbot0"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = 0
	//weight = 1.0E7
	var/amount = 50
	on = 1
	var/repairing = 0
	var/improvefloors = 0
	var/eattiles = 0
	var/maketiles = 0
	locked = 1
	health = 25
	var/const/max_tiles = 500
	var/atom/target
	var/atom/oldtarget
	var/oldloc = null
	req_access = list(access_engineering)
	access_lookup = "Chief Engineer"
	var/list/path = null
	no_camera = 1
	var/search_range = 1
	var/max_search_range = 7

	// this is from cleanbot.dm, which should really be like. part of all bots, later.
	var/list/targets_invalid = list() // Targets we weren't able to reach.
	var/clear_invalid_targets = 1 // In relation to world time. Clear list periodically.
	var/clear_invalid_targets_interval = 1800 // How frequently?


/obj/machinery/bot/floorbot/New()
	..()
	SPAWN_DBG(0.5 SECONDS)
		if (src)
			src.botcard = new /obj/item/card/id(src)
			src.botcard.access = get_access(src.access_lookup)
			src.updateicon()
	return

/obj/machinery/bot/floorbot/attack_hand(mob/user as mob, params)
	var/dat
	dat += text({"
<TT><B>Automatic Station Floor Repairer v1.0</B></TT><BR><BR>
Status: []<BR>
Tiles left: [src.amount]<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]"},
text("<A href='?src=\ref[src];operation=start'>[src.on ? "On" : "Off"]</A>"))
	if (!src.locked)
		dat += text({"<hr>
Improves floors: []<BR>
Finds tiles: []<BR>
Make single pieces of metal into tiles when empty: []"},
text("<A href='?src=\ref[src];operation=improve'>[src.improvefloors ? "Yes" : "No"]</A>"),
text("<A href='?src=\ref[src];operation=tiles'>[src.eattiles ? "Yes" : "No"]</A>"),
text("<A href='?src=\ref[src];operation=make'>[src.maketiles ? "Yes" : "No"]</A>"))

	if (user.client.tooltipHolder)
		user.client.tooltipHolder.showClickTip(src, list(
			"params" = params,
			"title" = "Repairbot v1.0 controls",
			"content" = dat,
		))

	return

/obj/machinery/bot/floorbot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if (user)
			boutput(user, "<span class='alert'>You short out [src]'s target assessment circuits.</span>")
		SPAWN_DBG(0)
			for (var/mob/O in hearers(src, null))
				O.show_message("<span class='alert'><B>[src] buzzes oddly!</B></span>", 1)
		src.target = null
		src.oldtarget = null
		src.anchored = 0
		src.emagged = 1
		src.on = 1
		src.icon_state = "floorbot[src.on]"
		return 1
	return 0


/obj/machinery/bot/floorbot/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair [src]'s target assessment circuits.", "blue")
	src.emagged = 0
	return 1

/obj/machinery/bot/floorbot/emp_act()
	..()
	if (!src.emagged && prob(75))
		src.visible_message("<span class='alert'><B>[src] buzzes oddly!</B></span>")
		src.target = null
		src.oldtarget = null
		src.anchored = 0
		src.emagged = 1
		src.on = 1
		src.icon_state = "floorbot[src.on]"
	else
		src.explode()
	return

/obj/machinery/bot/floorbot/attackby(var/obj/item/W , mob/user as mob)
	if (istype(W, /obj/item/tile))
		var/obj/item/tile/T = W
		if (src.amount >= max_tiles)
			return
		var/loaded = 0
		if (src.amount + T.amount > max_tiles)
			var/i = max_tiles - src.amount
			src.amount += i
			T.amount -= i
			loaded = i
		else
			src.amount += T.amount
			loaded = T.amount
			qdel(T)
		boutput(user, "<span class='alert'>You load [loaded] tiles into the floorbot. He now contains [src.amount] tiles!</span>")
		src.updateicon()
	//Regular ID
	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if (istype(W, /obj/item/card/id))
		if (src.allowed(usr))
			src.locked = !src.locked
			boutput(user, "You [src.locked ? "lock" : "unlock"] the [src] behaviour controls.")
		else
			boutput(user, "The [src] doesn't seem to accept your authority.")
		src.updateUsrDialog()



/obj/machinery/bot/floorbot/Topic(href, href_list)
	if (..())
		return
	src.add_dialog(usr)
	src.add_fingerprint(usr)
	switch(href_list["operation"])
		if ("start")
			src.on = !src.on
			src.target = null
			src.oldtarget = null
			src.oldloc = null
			src.updateicon()
			src.path = null
			src.updateUsrDialog()
		if ("improve")
			src.improvefloors = !src.improvefloors
			src.updateUsrDialog()
		if ("tiles")
			src.eattiles = !src.eattiles
			src.updateUsrDialog()
		if ("make")
			src.maketiles = !src.maketiles
			src.updateUsrDialog()

/obj/machinery/bot/floorbot/attack_ai()
	src.on = !src.on
	src.target = null
	src.oldtarget = null
	src.oldloc = null
	src.updateicon()
	src.path = null


/obj/machinery/bot/floorbot/proc/find_target(var/force = 0)
	if (!force && src.target && src.target != null)
		// you already have a target you clown get out of here
		return

	// Don't target things other floorbots are targetting
	var/list/floorbottargets = list()
	if (!src.target || src.target == null)
		for(var/obj/machinery/bot/floorbot/bot in machine_registry[MACHINES_BOTS])
			if (bot != src)
				floorbottargets += bot.target


	// Find thing to do
	if (!src.emagged && src.amount > 0)
		// We can only do these things while we have tiles...

	    // Search for space turf
		for (var/turf/space/D in view(src.search_range, src))
			if (D != src.oldtarget && (D.loc.name != "Space" && D.loc.name != "Ocean") && !(D in floorbottargets) && !should_ignore_tile(D))
				return D

		// Search for incomplete/damaged floor
		if (src.improvefloors)
			for (var/turf/simulated/floor/F in view(src.search_range, src))
				if (F != src.oldtarget && (!F.intact || F.burnt || F.broken || istype(F, /turf/simulated/floor/metalfoam)) && !(F in floorbottargets) && !should_ignore_tile(F))
					return F


	if (src.emagged)
		for (var/turf/simulated/floor/F in view(src.search_range, src))
			if (F != src.oldtarget && !(F in floorbottargets) && !should_ignore_tile(F))
				return F

	// Only do this if we don't have our max already
	if (src.amount < max_tiles)
		if (src.eattiles)
			for (var/obj/item/tile/T in view(src.search_range, src))
				// T is /var/turf, not. tiles. does this even work? does BYOND care?
				if (T != src.oldtarget && !(target in floorbottargets) && !should_ignore_tile(get_turf(T)))
					return T

		if (src.maketiles)
			if (src.target == null || !src.target)
				for (var/obj/item/sheet/M in view(src.search_range, src))
					if (M != src.oldtarget && !(M in floorbottargets) && M.amount >= 1 && !(istype(M.loc, /turf/simulated/wall)) && !should_ignore_tile(get_turf(M)))
						return M

	return null

/obj/machinery/bot/floorbot/proc/should_ignore_tile(var/turf/T)
	if (T in targets_invalid)
		return true

	for (var/atom/A in T.contents)
		if (A.density && !(A.flags & ON_BORDER) && !istype(A, /obj/machinery/door) && !ismob(A))
			targets_invalid += T
			return true



/obj/machinery/bot/floorbot/process()
	// checks to see if robot is on / busy already
	if (!src.on || src.repairing || !isturf(src.loc))
		return

	// Invalid targets may not be unreachable anymore. Clear list periodically.
	if (src.clear_invalid_targets && world.time > src.clear_invalid_targets + src.clear_invalid_targets_interval)
		src.targets_invalid = list()
		src.clear_invalid_targets = world.time


	if (prob(5))
		src.visible_message("[src] makes an excited booping beeping sound!")

	if (!src.target)
		do
			src.target	= src.find_target()
			src.search_range++
		while (!src.target && src.search_range <= 3)
		// basically: try to find a target within 3 tiles
		// if that doesn't work: just give up, go slower as search expands
		// will help keep a bot "focused" on an area
		src.search_range = min(src.max_search_range, src.target ? 1 : src.search_range)

		if (src.target)
			var/obj/decal/point/P = new(get_turf(src.target))
			P.pixel_x = target.pixel_x
			P.pixel_y = target.pixel_y
			SPAWN_DBG(2 SECONDS)
				P.invisibility = 101
				qdel(P)

		src.oldtarget = null

	if (src.target)

		// are we there yet
		if (get_turf(src.loc) == get_turf(src.target))
			do_the_thing()
			return

		// we are not there. how do we get there
		if (!src.path || !src.path.len)
			src.path = AStar(src.loc, get_turf(src.target), /turf/proc/CardinalTurfsSpace, /turf/proc/Distance, 120)
			if (!src.path || !src.path.len)
				// answer: we don't. try to find something else then.
				src.oldtarget = src.target
				targets_invalid += src.target
				src.target = null

		SPAWN_DBG(0)
			for (var/i = 4, i > 0, i--)
				if (src.path && src.path.len)
					step_to(src, src.path[1])
					src.path -= src.path[1]
					sleep(0.3 SECONDS)

			if (get_turf(src.loc) == get_turf(src.target))
				do_the_thing()
				return


/obj/machinery/bot/floorbot/proc/do_the_thing()
	// we are there, hooray
	if (istype(src.target, /obj/item/tile))
		src.eattile(src.target)
	else if (istype(src.target, /obj/item/sheet))
		src.maketile(src.target)
	else if (istype(src.target, /turf/))
		repair(src.target)

	src.path = null



/obj/machinery/bot/floorbot/proc/repair(var/turf/target)
	if (src.repairing)
		return
	if (!src.emagged)
		// are we doin this normally?

		if (src.amount < 0)
			// uh. buddy. you aint got no floor tiles.
			src.target = null
			return

		src.anchored = 1
		src.icon_state = "floorbot-c"
		src.repairing = 1
		var/new_tile = 0

		if (istype(target, /turf/space/) || istype(target, /turf/simulated/floor/metalfoam))
			src.visible_message("<span class='notice'>[src] begins building flooring.</span>")
			new_tile = 1

		else if (istype(target, /turf/simulated/floor))
			src.visible_message("<span class='notice'>[src] begins to fix the floor.</span>")

		else
			// how the fucking jesus did you get here
			src.target = null
			return

		SPAWN_DBG(0.4 SECONDS)
			if (new_tile)
				// Make a new tile
				var/obj/item/tile/T = new /obj/item/tile/steel
				T.build(src.loc)
			else
				// Fix yo shit
				var/turf/simulated/floor/F = target
				if (F.intact)
					F.to_plating()
					sleep(0.5 SECONDS)
				F.restore_tile()

			src.repairing = 0
			src.amount -= 1
			src.updateicon()
			src.anchored = 0
			src.target = find_target(1)
			return

	else if (src.emagged && istype(target, /turf/simulated/floor))
		// Emagged "repair"

		src.visible_message("<span class='alert'>[src] starts ripping up the flooring!</span>")
		src.anchored = 1
		src.repairing = 1
		SPAWN_DBG(1 SECOND)
			// literally rip up the floor tile. honk.
			var/turf/simulated/floor/T = target
			var/atom/A = new /obj/item/tile(T)
			if (T.material)
				A.setMaterial(T.material)
			else
				var/datum/material/M = getMaterial("steel")
				A.setMaterial(M)

			T.ReplaceWithSpace()
			src.repairing = 0
			src.updateicon()
			src.anchored = 0
			src.target = find_target(1)
		return


/obj/machinery/bot/floorbot/proc/eattile(var/obj/item/tile/T)
	if (!istype(T, /obj/item/tile))
		return
	src.visible_message("<span class='alert'>[src] begins to collect tiles.</span>")
	src.repairing = 1
	SPAWN_DBG(0.2 SECONDS)
		if (isnull(T))
			src.target = null
			src.repairing = 0
			return
		if (src.amount + T.amount > max_tiles)
			var/i = max_tiles - src.amount
			src.amount += i
			T.amount -= i
		else
			src.amount += T.amount
			qdel(T)
		src.updateicon()
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/maketile(var/obj/item/sheet/M)
	if (!istype(M, /obj/item/sheet))
		return
	src.visible_message("<span class='alert'>[src] begins to create tiles.</span>")
	src.repairing = 1
	M.set_loc(src)
	SPAWN_DBG(0.2 SECONDS)
		if (isnull(M))
			src.target = null
			src.repairing = 0
			return

		var/sheets_to_use = 1
		if (src.amount + (M.amount * 4) > src.max_tiles)
			sheets_to_use = round((src.max_tiles - src.amount) / 4)
		else
			sheets_to_use = M.amount

		var/obj/item/tile/T = new /obj/item/tile/steel
		T.set_loc(get_turf(src))
		M.set_loc(get_turf(src))
		T.amount = sheets_to_use * 4
		M.amount -= sheets_to_use
		if (M.amount < 1)
			qdel(M)
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/updateicon()
	if (src.amount > 0)
		src.icon_state = "floorbot[src.on]"
	else
		src.icon_state = "floorbot[src.on]e"


/////////////////////////////////////////
//////Floorbot Construction/////////////
/////////////////////////////////////////
/obj/item/storage/toolbox/mechanical/attackby(var/obj/item/tile/T, mob/user as mob)
	if (!istype(T, /obj/item/tile))
		..()
		return
	if (src.contents.len >= 1)
		boutput(user, "They wont fit in as there is already stuff inside!")
		return
	var/obj/item/toolbox_tiles/B = new /obj/item/toolbox_tiles
	user.u_equip(T)
	user.put_in_hand_or_drop(B)
	boutput(user, "You add the tiles into the empty toolbox. They stick oddly out the top.")
	qdel(T)
	qdel(src)

/obj/item/toolbox_tiles/attackby(var/obj/item/device/prox_sensor/D, mob/user as mob)
	if (!istype(D, /obj/item/device/prox_sensor))
		return
	var/obj/item/toolbox_tiles_sensor/B = new /obj/item/toolbox_tiles_sensor
	B.set_loc(user)
	user.u_equip(D)
	user.put_in_hand_or_drop(B)
	boutput(user, "You add the sensor to the toolbox and tiles!")
	qdel(D)
	qdel(src)

/obj/item/toolbox_tiles_sensor/attackby(var/obj/item/parts/robot_parts/P, mob/user as mob)
	if (!istype(P, /obj/item/parts/robot_parts/arm/))
		return
	var/obj/machinery/bot/floorbot/A = new /obj/machinery/bot/floorbot
	if (user.r_hand == src || user.l_hand == src)
		A.set_loc(user.loc)
	else
		A.set_loc(src.loc)
	boutput(user, "You add the robot arm to the odd looking toolbox assembly! Boop beep!")
	qdel(P)
	qdel(src)

/obj/machinery/bot/floorbot/explode()
	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	for (var/mob/O in hearers(src, null))
		O.show_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
	elecflash(src, radius=1, power=3, exclude_center = 0)
	qdel(src)
	return
