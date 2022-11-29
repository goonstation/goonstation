//Floorbot assemblies
#define FLOORBOT_MOVE_SPEED 7
#define FLOORBOT_CLEARTARGET_COOLDOWN "clearinvalidfloorbotlist"
/obj/item/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top"
	name = "tiles and toolbox"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "toolbox_tiles"
	force = 3
	throwforce = 10
	throw_speed = 2
	throw_range = 5
	w_class = W_CLASS_NORMAL
	flags = TABLEPASS
	var/color_overlay = null // default blue floorbot

/obj/item/toolbox_tiles_sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached"
	name = "tiles, toolbox and sensor arrangement"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "toolbox_tiles_sensor"
	force = 3
	throwforce = 10
	throw_speed = 2
	throw_range = 5
	w_class = W_CLASS_NORMAL
	flags = TABLEPASS
	var/color_overlay = null // default blue floorbot

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
	on = 0 // Don't start running around eating everything and puking it all over the cold loop, at least till someone pokes you
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
	/// and they lag to shit at higher processing levels (i actually fixed that lag, but theyre kinda good at this rate sooo)
	dynamic_processing = 0
	PT_idle = PROCESSING_QUARTER
	var/color_overlay = null // default blue floorbot

	var/static/list/floorbottargets = list()

	// this is from cleanbot.dm, which should really be like. part of all bots, later.
	var/list/targets_invalid = list() // Targets we weren't able to reach.
	var/clear_invalid_targets = 1 // In relation to world time. Clear list periodically.
	var/clear_invalid_targets_interval = 30 SECONDS // How frequently?

	var/list/chase_lines = list("Gimme!", "Hey!", "Oi!", "Mine!", "Want!", "Need!")

	proc/update_power_overlay()
		if(src.on)
			src.UpdateOverlays(image(src.icon, icon_state = "floorbot_overlay_power_on"), "poweroverlay")
		else
			src.UpdateOverlays(image(src.icon, icon_state = "floorbot_overlay_power_off"), "poweroverlay")


/obj/machinery/bot/floorbot/New()
	..()
	SPAWN(0.5 SECONDS)
		if (src)
			src.update_power_overlay()
			src.UpdateIcon()
	return

/obj/machinery/bot/floorbot/attack_hand(mob/user, params)
	var/dat
	dat += "<TT><B>Automatic Station Floor Repairer v1.0</B></TT><BR><BR>"
	dat += "Status: \[<A href='?src=\ref[src];operation=start'>[src.on ? "On" : "Off"]</A>\]<BR>"
	dat += "Tiles left: [src.amount]<BR>"
	dat += "Behaviour controls are [src.locked ? "locked" : "unlocked"]<BR>"
	if (!src.locked)
		dat += "<hr>"
		dat += "Improves floors: \[<A href='?src=\ref[src];operation=improve'>[src.improvefloors ? "Yes" : "No"]</A>\]<BR>"
		dat += "Finds tiles: \[<A href='?src=\ref[src];operation=tiles'>[src.eattiles ? "Yes" : "No"]</A>\]<BR>"
		dat += "Make single pieces of metal into tiles when empty: \[<A href='?src=\ref[src];operation=make'>[src.maketiles ? "Yes" : "No"]</A>\]"

	if (user.client?.tooltipHolder)
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
		src.KillPathAndGiveUp(1)
		src.emagged = 1
		src.on = 1
		src.update_power_overlay()
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
		src.KillPathAndGiveUp(1)
		src.emagged = 1
		src.on = 1
		src.update_power_overlay()
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
		src.UpdateIcon()
	//Regular ID
	else
		if (istype(W, /obj/item/device/pda2) && W:ID_card)
			W = W:ID_card
		if (istype(W, /obj/item/card/id))
			if (src.allowed(user))
				src.locked = !src.locked
				boutput(user, "You [src.locked ? "lock" : "unlock"] the [src] behaviour controls.")
			else
				boutput(user, "The [src] doesn't seem to accept your authority.")
			src.updateUsrDialog()
		else
			..()
			src.health -= W.force * 0.5
			if (src.health <= 0)
				src.explode()

/obj/machinery/bot/floorbot/Topic(href, href_list)
	if (..())
		return
	src.add_dialog(usr)
	src.add_fingerprint(usr)
	switch(href_list["operation"])
		if ("start")
			src.on = !src.on
			src.update_power_overlay()
			src.KillPathAndGiveUp(1)
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
	src.update_power_overlay()
	src.KillPathAndGiveUp(1)

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
				if(!istype(D, /turf/space))
					continue
				var/coord = turf2coordinates(D)
				if((coord in floorbottargets) || (coord in targets_invalid))
					continue
				else if (D == src.oldtarget || should_ignore_tile(D))
					continue
				// Floorbot doesnt like space, so it won't accept space tiles without some kind of not-space next to it. Or they're right up against it. Or already on space.
				else if ((BOUNDS_DIST(get_turf(src), get_turf(D)) == 0) || get_pathable_turf(D)) // silly little things
					src.floorbottargets |= coord
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
						src.floorbottargets |= coord
						return F

	if (src.emagged)
		for (var/turf/simulated/floor/F in view(src.search_range, src.scan_origin))
			var/coord = turf2coordinates(F)
			if((coord in floorbottargets) || (coord in targets_invalid))
				continue
			else if (F == src.oldtarget || should_ignore_tile(F))
				continue
			else
				src.floorbottargets |= coord
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
					src.floorbottargets |= coord
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
						src.floorbottargets |= coord
						return M

	return null

/obj/machinery/bot/floorbot/proc/should_ignore_tile(var/turf/T)
	for (var/atom/A in T.contents)
		if (A.density && !(A.flags & ON_BORDER) && !istype(A, /obj/machinery/door) && !ismob(A))
			var/coord = turf2coordinates(get_turf(A))
			targets_invalid |= coord
			return true



/obj/machinery/bot/floorbot/process()
	. = ..()
	// checks to see if robot is on / busy already
	if (!src.on || src.repairing || !isturf(src.loc))
		return

	if (src.target?.disposed || !isturf(get_turf(src.target)))
		src.target = null

	// Invalid targets may not be unreachable anymore. Clear list periodically.
	if (src.clear_invalid_targets && !ON_COOLDOWN(src, FLOORBOT_CLEARTARGET_COOLDOWN, src.clear_invalid_targets_interval))
		src.targets_invalid = list()
		src.floorbottargets = list()

	if (!src.target)
		for(var/i in 1 to src.max_search_range)
			// basically: focus on scanning tiles near to a set area
			// scan in a small area, and if nothing's found, scan a larger area
			// will help keep a bot "focused" on an area
			if(!src.scan_origin || !isturf(src.scan_origin) || !IN_RANGE(get_turf(src), src.scan_origin, 7))
				src.scan_origin = get_turf(src)
			src.search_range = i
			src.target = src.find_target()
			if(src.target)
				break
			if(!src.target && src.search_range++ >= src.max_search_range)
				src.KillPathAndGiveUp(1)

	if (src.target)
		// are we there yet
		if ((BOUNDS_DIST(get_turf(src), get_turf(src.target)) == 0))
			do_the_thing()
			return

		// we are not there. how do we get there
		if (!src.path || !length(src.path))
			src.navigate_to(get_turf(src.target), FLOORBOT_MOVE_SPEED, max_dist = 20)
			if (!src.path || !length(src.path))
				// answer: we don't. try to find something else then.
				src.targets_invalid |= turf2coordinates(src.target)
				src.KillPathAndGiveUp(1)
				return
		src.point(src.target)
		var/obj/A = src.target
		while(!isnull(A) && !istype(A.loc, /turf) && !ishuman(A.loc))
			A = A.loc
		if (ishuman(A?.loc) && prob(30))
			speak(pick(src.chase_lines))
		src.doing_something = 1
		src.search_range = 1
	else
		src.targets_invalid |= turf2coordinates(src.target)
		src.KillPathAndGiveUp(1)

/obj/machinery/bot/floorbot/KillPathAndGiveUp(var/give_up)
	. = ..()
	if(give_up)
		src.floorbottargets -= turf2coordinates(src.target)
		src.target = null
		src.anchored = 0
		src.UpdateIcon()
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
	src.UpdateIcon()
	src.floorbottargets -= turf2coordinates(src.target)
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
	src.floorbottargets -= turf2coordinates(src.target)
	src.target = null
	src.repairing = 0

/obj/machinery/bot/floorbot/update_icon()
	if (src.amount > 0)
		src.icon_state = "floorbot[src.on]"
	else
		src.icon_state = "floorbot[src.on]e"


/////////////////////////////////
//////Floorbot Construction//////
/////////////////////////////////
// Construction begins in /obj/item/storage/toolbox/attackby

/obj/item/toolbox_tiles/attack_self(mob/user)
	for(var/obj/item/I in src.contents) // toolbox
		user.put_in_hand_or_drop(I)
		qdel(src)
	boutput(user, "You discard the tile and recover the toolbox!")

/obj/item/toolbox_tiles/attackby(var/obj/item/device/prox_sensor/D, mob/user as mob)
	if (!istype(D, /obj/item/device/prox_sensor))
		return
	var/obj/item/toolbox_tiles_sensor/B = new /obj/item/toolbox_tiles_sensor
	if(src.color_overlay)
		B.UpdateOverlays(image(B.icon, icon_state = src.color_overlay), "coloroverlay")
		B.color_overlay = src.color_overlay
	B.UpdateOverlays(image(B.icon, icon_state = "floorbot_overlay_power_off"), "poweroverlay")
	B.set_loc(user)
	user.u_equip(D)
	user.put_in_hand_or_drop(B)
	boutput(user, "You add the sensor to the toolbox and tiles!")
	// No going back now!
	qdel(D)
	qdel(src)

/obj/item/toolbox_tiles_sensor/attackby(var/obj/item/parts/robot_parts/P, mob/user as mob)
	if (!istype(P, /obj/item/parts/robot_parts/arm/))
		return
	var/obj/machinery/bot/floorbot/A = new /obj/machinery/bot/floorbot
	if(src.color_overlay)
		A.UpdateOverlays(image(A.icon, icon_state = src.color_overlay), "coloroverlay")
		A.color_overlay = src.color_overlay
	if (user.r_hand == src || user.l_hand == src)
		A.set_loc(user.loc)
	else
		A.set_loc(src.loc)
	A.on = 1 // let's just pretend they flipped the switch
	A.update_power_overlay()
	boutput(user, "You add the robot arm to the odd looking toolbox assembly! Boop beep!")
	qdel(P)
	qdel(src)

/obj/machinery/bot/floorbot/explode()
	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	src.visible_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
	playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 40, 1)
	elecflash(src, radius=1, power=3, exclude_center = 0)
	new /obj/item/tile/steel(src.loc)
	new /obj/item/device/prox_sensor(src.loc)
	new /obj/item/storage/toolbox/mechanical/empty(src.loc)
	qdel(src)
	return

/datum/action/bar/icon/floorbot_repair
	duration = 10
	interrupt_flags = INTERRUPT_STUNNED
	id = "floorbot_build"
	icon = 'icons/obj/metal.dmi'
	icon_state = "tile"
	var/obj/machinery/bot/floorbot/master
	var/new_tile

	New(var/the_bot, var/_target)
		src.master = the_bot
		if(!istype(src.master))
			interrupt(INTERRUPT_ALWAYS)
			return

		master.anchored = 1
		master.icon_state = "floorbot-c"
		master.repairing = 1
		src.new_tile = 0

		if (istype(master.target, /turf/space/) || istype(master.target, /turf/simulated/floor/metalfoam))
			master.visible_message("<span class='notice'>[master] begins building flooring.</span>")
			src.new_tile = 1

		else if (istype(master.target, /turf/simulated/floor))
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
		playsound(master, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, 1)

	onInterrupt()
		. = ..()
		master.KillPathAndGiveUp(1)

	onEnd()
		..()
		if (!master.target)
			return
		playsound(master, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, 1)
		if (new_tile)
			// Make a new tile
			var/obj/item/tile/T = new /obj/item/tile/steel
			T.build(get_turf(master.target))
		else
			// Fix yo shit
			var/turf/simulated/floor/F = master.target
			if (F.intact)
				F.to_plating()
			F.restore_tile()

		master.repairing = 0
		master.amount -= 1
		master.UpdateIcon()
		master.anchored = 0
		master.floorbottargets -= master.turf2coordinates(master.target)
		master.target = master.find_target(1)

/datum/action/bar/icon/floorbot_disrepair
	duration = 10
	interrupt_flags = INTERRUPT_STUNNED
	id = "floorbot_ripup"
	icon = 'icons/obj/metal.dmi'
	icon_state = "tile"
	var/obj/machinery/bot/floorbot/master

	New(var/the_bot, var/_target)
		src.master = the_bot

		master.anchored = 1
		master.icon_state = "floorbot-c"
		master.repairing = 1

		..()

	onUpdate()
		..()
		if (!master.on)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/turf/simulated/floor/T = master.target
		if(!istype(T))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (!master.on)
			interrupt(INTERRUPT_ALWAYS)
			return
		attack_twitch(master)
		playsound(master, 'sound/items/Welder.ogg', 50, 1)

	onInterrupt()
		. = ..()
		master.KillPathAndGiveUp(1)

	onEnd()
		..()
		playsound(master, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, 1)
		var/turf/simulated/floor/T = master.target
		if(!istype(T))
			interrupt(INTERRUPT_ALWAYS)
			return
		var/atom/A = new /obj/item/tile(T)
		if (T.material)
			A.setMaterial(T.material)
		else
			var/datum/material/M = getMaterial("steel")
			A.setMaterial(M)

		T.ReplaceWithSpace()
		master.repairing = 0
		master.UpdateIcon()
		master.anchored = 0
		master.floorbottargets -= master.turf2coordinates(master.target)
		master.target = master.find_target(1)
