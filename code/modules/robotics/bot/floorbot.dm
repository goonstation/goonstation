//Floorbot assemblies
#define FLOORBOT_MOVE_SPEED 7
#define FLOORBOT_CLEARTARGET_COOLDOWN "clearinvalidfloorbotlist"
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
	bot_move_delay = FLOORBOT_MOVE_SPEED
	//weight = 1.0E7
	var/amount = 50
	on = 1
	var/repairing = 0
	var/improvefloors = 0
	var/eattiles = 1
	var/maketiles = 1
	locked = 1
	health = 25
	var/const/max_tiles = 500
	var/atom/target
	var/atom/oldtarget
	var/oldloc = null
	req_access = list(access_engineering)
	access_lookup = "Chief Engineer"
	no_camera = 1
	var/search_range = 1
	var/max_search_range = 7
	/// Favor scanning from this spot, so that they'll tend to build out from here, and not just a bunch of metal spaghetti
	var/turf/scan_origin
	/// They're designed to work best while nobody's looking
	/// and they lag to shit at higher processing levels
	dynamic_processing = 0
	PT_idle = PROCESSING_QUARTER

	var/static/list/floorbottargets = list()

	// this is from cleanbot.dm, which should really be like. part of all bots, later.
	var/list/targets_invalid = list() // Targets we weren't able to reach.
	var/clear_invalid_targets = 1 // In relation to world time. Clear list periodically.
	var/clear_invalid_targets_interval = 10 MINUTES // How frequently?


/obj/machinery/bot/floorbot/New()
	..()
	SPAWN_DBG(0.5 SECONDS)
		if (src)
			src.updateicon()
	return

/obj/machinery/bot/floorbot/attack_hand(mob/user as mob, params)
	var/dat
	dat += "<TT><B>Automatic Station Floor Repairer v1.0</B></TT><BR><BR>"
	dat += "Status: []<BR>"
	dat += "Tiles left: [src.amount]<BR>"
	dat += "Behaviour controls are [src.locked ? "locked" : "unlocked"]"
	dat += "<A href='?src=\ref[src];operation=start'>[src.on ? "On" : "Off"]</A>"
	if (!src.locked)
		dat += "<hr>"
		dat += "Improves floors: []<BR>"
		dat += "Finds tiles: []<BR>"
		dat += "Make single pieces of metal into tiles when empty: []"
		dat += "<A href='?src=\ref[src];operation=improve'>[src.improvefloors ? "Yes" : "No"]</A>"
		dat += "<A href='?src=\ref[src];operation=tiles'>[src.eattiles ? "Yes" : "No"]</A>"
		dat += "<A href='?src=\ref[src];operation=make'>[src.maketiles ? "Yes" : "No"]</A>"

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
		src.audible_message("<span class='alert'><B>[src] buzzes oddly!</B></span>", 1)
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
		if (src.allowed(user))
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

	if(!src.scan_origin || !isturf(src.scan_origin))
		src.scan_origin = get_turf(src)

	// Find thing to do
	if (!src.emagged)
		if(src.amount > 0)
			// We can only do these things while we have tiles...

			// Search for space turf
			for (var/turf/space/D in view(src.search_range, src.scan_origin))
				var/coord = turf2coordinates(D)
				if((coord in floorbottargets) || (coord in targets_invalid))
					continue
				else if (D == src.oldtarget || should_ignore_tile(D))
					continue
				else
					src.floorbottargets += coord
					return D

			// Search for incomplete/damaged floor
			if (src.improvefloors)
				for (var/turf/simulated/floor/F in view(src.search_range, src.scan_origin))
					var/coord = turf2coordinates(F)
					if((coord in floorbottargets) || (coord in targets_invalid))
						continue
					else if (F == src.oldtarget || should_ignore_tile(F))
						continue
					else if (!F.intact || F.burnt || F.broken || istype(F, /turf/simulated/floor/metalfoam))
						src.floorbottargets += coord
						return F

	if (src.emagged)
		for (var/turf/simulated/floor/F in view(src.search_range, src.scan_origin))
			var/coord = turf2coordinates(F)
			if((coord in floorbottargets) || (coord in targets_invalid))
				continue
			else if (F == src.oldtarget || should_ignore_tile(F))
				continue
			else
				src.floorbottargets += coord
				return F

	// Only do this if we don't have our max already
	if (src.amount < max_tiles)
		if (src.eattiles)
			for (var/obj/item/tile/T in view(src.search_range, src.scan_origin))
				var/coord = turf2coordinates(get_turf(T))
				if((coord in floorbottargets) || (coord in targets_invalid))
					continue
				else if (T == src.oldtarget || should_ignore_tile(T))
					continue
				else
					src.floorbottargets += coord
					return T
					// T is /var/turf, not. tiles. does this even work? does BYOND care? no, not really

		if (src.maketiles)
			if (src.target == null || !src.target)
				for (var/obj/item/sheet/M in view(src.search_range, src.scan_origin))
					var/coord = turf2coordinates(get_turf(M))
					if((coord in floorbottargets) || (coord in targets_invalid))
						continue
					else if (M == src.oldtarget || should_ignore_tile(M))
						continue
					else if (M.amount >= 1 && !(istype(M.loc, /turf/simulated/wall)) && !should_ignore_tile(get_turf(M)))
						src.floorbottargets += coord
						return M

	return null

/obj/machinery/bot/floorbot/proc/should_ignore_tile(var/turf/T)
	for (var/atom/A in T.contents)
		if (A.density && !(A.flags & ON_BORDER) && !istype(A, /obj/machinery/door) && !ismob(A))
			var/coord = turf2coordinates(get_turf(A))
			targets_invalid += coord
			return true



/obj/machinery/bot/floorbot/process()
	. = ..()
	// checks to see if robot is on / busy already
	if (!src.on || src.repairing || !isturf(src.loc))
		return

	// Invalid targets may not be unreachable anymore. Clear list periodically.
	if (src.clear_invalid_targets && !ON_COOLDOWN(src, FLOORBOT_CLEARTARGET_COOLDOWN, src.clear_invalid_targets_interval))
		src.targets_invalid = list()
		src.floorbottargets = list()

	if (!src.target)
		// basically: try to find a target within 3 tiles
		// if that doesn't work: just give up, go slower as search expands
		// will help keep a bot "focused" on an area
		if(!src.scan_origin || !isturf(src.scan_origin))
			src.scan_origin = get_turf(src)
		src.target = src.find_target()

	if (src.target)
		src.point(src.target)
		src.doing_something = 1
		src.search_range = 1

		// are we there yet
		if (get_turf(src.loc) == get_turf(src.target))
			do_the_thing()
			return

		// we are not there. how do we get there
		if (!src.path || !src.path.len)
			src.navigate_to(get_turf(src.target), FLOORBOT_MOVE_SPEED, max_dist = 120)
			if (!src.path || !src.path.len)
				// answer: we don't. try to find something else then.
				src.KillPathAndGiveUp(1)
	else // No targets found in range? Increase the range!
		if(src.search_range++ > src.max_search_range)
			src.KillPathAndGiveUp(1)
	if(frustration >= 8)
		src.KillPathAndGiveUp(1)

/obj/machinery/bot/floorbot/KillPathAndGiveUp(var/give_up)
	. = ..()
	if(give_up)
		src.targets_invalid += src.target
		src.floorbottargets -= turf2coordinates(src.target)
		src.target = null
		src.anchored = 0
		src.updateicon()
		src.repairing = 0
		src.oldtarget = null
		src.oldloc = null
		src.search_range = 1
		src.scan_origin = null

/obj/machinery/bot/floorbot/proc/do_the_thing()
	// we are there, hooray
	if (prob(80))
		src.visible_message("[src] makes an excited booping beeping sound!")
	if (istype(src.target, /obj/item/tile))
		src.eattile(src.target)
	else if (istype(src.target, /obj/item/sheet))
		src.maketile(src.target)
	else if (istype(src.target, /turf/))
		src.repair(src.target)

/obj/machinery/bot/floorbot/proc/repair(var/turf/target)
	if (src.repairing)
		return
	if (!src.emagged)
		// are we doin this normally?
		if (src.amount < 0)
			// uh. buddy. you aint got no floor tiles.
			src.KillPathAndGiveUp(1)
			return
		actions.start(new/datum/action/bar/icon/floorbot_repair(src, target), src)

	else if (src.emagged && istype(target, /turf/simulated/floor))
		// Emagged "repair"
		actions.start(new/datum/action/bar/icon/floorbot_disrepair(src, target), src)

/obj/machinery/bot/floorbot/proc/eattile(var/obj/item/tile/T)
	if (!istype(T, /obj/item/tile))
		return
	src.visible_message("<span class='alert'>[src] gathers up [T] into its hopper.</span>")
	src.repairing = 1
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
	src.visible_message("<span class='alert'>[src] converts [M] into usable floor tiles.</span>")
	src.repairing = 1
	M.set_loc(src)
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
	src.visible_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
	playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 40, 1)
	elecflash(src, radius=1, power=3, exclude_center = 0)
	qdel(src)
	return

/datum/action/bar/icon/floorbot_repair
	duration = 10
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "floorbot_build"
	icon = 'icons/obj/metal.dmi'
	icon_state = "tile"
	var/obj/machinery/bot/floorbot/master
	var/target
	var/new_tile

	New(var/the_bot, var/_target)
		src.master = the_bot
		src.target = _target

		master.anchored = 1
		master.icon_state = "floorbot-c"
		master.repairing = 1
		src.new_tile = 0

		if (istype(target, /turf/space/) || istype(target, /turf/simulated/floor/metalfoam))
			master.visible_message("<span class='notice'>[master] begins building flooring.</span>")
			src.new_tile = 1

		else if (istype(target, /turf/simulated/floor))
			master.visible_message("<span class='notice'>[master] begins to fix the floor.</span>")

		else
			// how the fucking jesus did you get here
			interrupt(INTERRUPT_ALWAYS)
			return

		..()

	onUpdate()
		..()
		if (!master.on)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (!master.on)
			interrupt(INTERRUPT_ALWAYS)
			return
		attack_twitch(master)
		playsound(get_turf(master), "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)

	onInterrupt()
		. = ..()
		if(master.target) // release our claim on this target
			master.floorbottargets -= master.turf2coordinates(master.target)
		master.KillPathAndGiveUp(1)

	onEnd()
		..()
		playsound(get_turf(master), "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)
		if (new_tile)
			// Make a new tile
			var/obj/item/tile/T = new /obj/item/tile/steel
			T.build(master.loc)
		else
			// Fix yo shit
			var/turf/simulated/floor/F = target
			if (F.intact)
				F.to_plating()
			F.restore_tile()

		master.repairing = 0
		master.amount -= 1
		master.updateicon()
		master.anchored = 0
		master.floorbottargets -= master.turf2coordinates(master.target)
		master.target = master.find_target(1)

/datum/action/bar/icon/floorbot_disrepair
	duration = 10
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "floorbot_ripup"
	icon = 'icons/obj/metal.dmi'
	icon_state = "tile"
	var/obj/machinery/bot/floorbot/master
	var/target

	New(var/the_bot, var/_target)
		src.master = the_bot
		src.target = _target

		master.anchored = 1
		master.icon_state = "floorbot-c"
		master.repairing = 1

		..()

	onUpdate()
		..()
		if (!master.on)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (!master.on)
			interrupt(INTERRUPT_ALWAYS)
			return
		attack_twitch(master)
		playsound(get_turf(master), 'sound/items/Welder.ogg', 50, 1)

	onInterrupt()
		. = ..()
		if(master.target) // release our claim on this target
			master.floorbottargets -= master.turf2coordinates(master.target)
		master.KillPathAndGiveUp(1)

	onEnd()
		..()
		playsound(get_turf(master), "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)
		var/turf/simulated/floor/T = target
		var/atom/A = new /obj/item/tile(T)
		if (T.material)
			A.setMaterial(T.material)
		else
			var/datum/material/M = getMaterial("steel")
			A.setMaterial(M)

		T.ReplaceWithSpace()
		master.repairing = 0
		master.updateicon()
		master.anchored = 0
		master.floorbottargets -= master.turf2coordinates(master.target)
		master.target = master.find_target(1)
