//Firebot
//Firebot assembly

#define FIREBOT_MOVE_SPEED 8
#define FIREBOT_SEARCH_COOLDOWN "look4fire"
#define FIREBOT_SPRAY_COOLDOWN "spraycooldown"
#define EXTINGUISH_HOTSPOTS 1
#define EXTINGUISH_ITEMS 2
#define EXTINGUISH_MOBS 4

/obj/machinery/bot/firebot
	name = "Firebot"
	desc = "A little fire-fighting robot!  He looks so darn chipper."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "firebot0"
	event_handler_flags = USE_PROXIMITY | USE_FLUID_ENTER
	flags =  FPRINT | FLUID_SUBMERGE | TGUI_INTERACTIVE | DOORPASS
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = UNANCHORED
	req_access = list(access_engineering_atmos)
	on = 1
	health = 20
	locked = 1
	access_lookup = "Captain"
	bot_move_delay = FIREBOT_MOVE_SPEED
	var/obj/hotspot/target = null
	var/obj/hotspot/oldtarget = null
	var/oldloc = null
	var/found_cooldown = 5 SECONDS
	var/spray_cooldown = 3 SECONDS
	/// If we pointed at someone, don't keep pointing at them, its rude
	var/last_pointed = null
	var/setup_party = 0
	var/extinguish_flags = EXTINGUISH_HOTSPOTS | EXTINGUISH_ITEMS | EXTINGUISH_MOBS
	var/water_amt = 2
	var/foam_amt = 8
	//To-Do: Patrol the station for fires maybe??

/obj/machinery/bot/firebot/party
	name = "Partybot"
	desc = "Isn't that a firebot? What's his deal?"
	emagged = 1
	setup_party = 1

//
/obj/item/toolbox_arm
	name = "toolbox/robot arm assembly"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "toolbox_arm"
	force = 3
	throwforce = 10
	throw_speed = 2
	throw_range = 5
	w_class = W_CLASS_NORMAL
	flags = TABLEPASS
	var/extinguisher = 0 //Is the extinguisher added?
	var/created_name = "Firebot"

/obj/machinery/bot/firebot/New()
	..()
	SPAWN(0.5 SECONDS)
		if (src)
			src.icon_state = "firebot[src.on]"

//		if(radio_connection)
//			radio_controller.add_object(src, "[beacon_freq]")


/obj/machinery/bot/firebot/attack_ai(mob/user as mob, params)
	var/dat
	dat += "<TT><B>Automatic Fire-Fighting Unit v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A><BR>"

//	dat += "<br>Behaviour controls are [src.locked ? "locked" : "unlocked"]<hr>"
//	if(!src.locked)
//To-Do: Behavior control stuff to go with ~fire patrols~

	if (user.client?.tooltipHolder)
		user.client.tooltipHolder.showClickTip(src, list(
			"params" = params,
			"title" = "Firebot v1.0 controls",
			"content" = dat,
		))

/obj/machinery/bot/firebot/attack_hand(mob/user, params)
	var/dat
	dat += "<TT><B>Automatic Fire-Fighting Unit v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A><BR>"

//	dat += "<br>Behaviour controls are [src.locked ? "locked" : "unlocked"]<hr>"
//	if(!src.locked)
//To-Do: Behavior control stuff to go with ~fire patrols~

	if (user.client?.tooltipHolder)
		user.client.tooltipHolder.showClickTip(src, list(
			"params" = params,
			"title" = "Firebot v1.0 controls",
			"content" = dat,
		))

	return

/obj/machinery/bot/firebot/Topic(href, href_list)
	if(..())
		return
	src.add_dialog(usr)
	src.add_fingerprint(usr)
	if ((href_list["power"]) && (src.allowed(usr)))
		src.toggle_power()


	src.updateUsrDialog()
	return

/obj/machinery/bot/firebot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if(user)
			boutput(user, "<span class='alert'>You short out [src]'s valve control circuit!</span>")
		src.audible_message("<span class='alert'><B>[src] buzzes oddly!</B></span>")
		flick("firebot_spark", src)
		src.KillPathAndGiveUp(1)
		src.emagged = 1
		src.on = 1
		src.icon_state = "firebot[src.on]"
		logTheThing(LOG_STATION, user, "emagged a [src] at [log_loc(src)].")
		return 1
	return 0


/obj/machinery/bot/firebot/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair [src]'s valve control circuit.", "blue")
	src.emagged = 0
	return 1

/obj/machinery/bot/firebot/emp_act()
	..()
	if (!src.emagged && prob(75))
		src.visible_message("<span class='alert'><B>[src] buzzes oddly!</B></span>")
		flick("firebot_spark", src)
		src.KillPathAndGiveUp(1)
		src.emagged = 1
		src.on = 1
		src.icon_state = "firebot[src.on]"
	else
		src.explode()
	return

/obj/machinery/bot/firebot/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/card/emag))
		//Swedenfact:
		//"Fart" means "speed", so if a policeman pulls you over with the words "fartkontroll" you should not pull your pants down
		return
	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if (istype(W, /obj/item/card/id))
		if (src.allowed(user))
			src.locked = !src.locked
			boutput(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
			src.updateUsrDialog()
		else
			boutput(user, "<span class='alert'>Access denied.</span>")

	else if (isscrewingtool(W))
		if (src.health < initial(src.health))
			src.health = initial(src.health)
			src.visible_message("<span class='notice'>[user] repairs [src]!</span>", "<span class='notice'>You repair [src].</span>")
	else
		switch(W.hit_type)
			if (DAMAGE_BURN)
				src.health -= W.force * 0.1 //more fire resistant than other bots
			else
				src.health -= W.force * 0.5
		if (src.health <= 0)
			src.explode()
		else if (W.force)
			step_to(src, (get_step_away(src,user)))
		..()

/obj/machinery/bot/firebot/process()
	. = ..()
	if(!src.on)
		src.stunned = 0
		src.KillPathAndGiveUp(1)
		return

	if(src.stunned)
		src.icon_state = "firebota"
		src.stunned--
		src.KillPathAndGiveUp(1)
		if(src.stunned <= 0)
			src.icon_state = "firebot[src.on]"
			src.stunned = 0
		return

	if(src.frustration > 8)
		src.KillPathAndGiveUp(1)

	if(src.target) // is our target still on fire?
		if(src.emagged)
			if(!IN_RANGE(src, src.target, 5) && prob(25))
				src.speak(pick("ONE FIRE, ONE EXTINGUISHER.", "HEAT DEATH: DELAYED.", "TARGET FIRE TRIANGLE: DISRUPTED.", "FIRE DESTROYED.",
											"AN EXTINGUISHER TO THE FACE KEEPS ME AWAY.", "YOU HAVE OUTRUN AN INFERNO", "GOD MADE TOMORROW FOR THE FIRES WE DON'T KILL TODAY."))
				src.KillPathAndGiveUp(1)
		else if(!(src.target in by_cat[TR_CAT_BURNING_ITEMS]) && !(src.target in by_cat[TR_CAT_BURNING_MOBS]) && !(src.target in by_type[/obj/hotspot]))
			src.speak(pick("FIRE: [pick("ENDED", "MURDERED", "STARVED", "KILLED", "DEAD", "DESTROYED")].", "FIRE SAFETY PROTOCOLS: OBSERVED.",
										 "TARGET CREATURE, OBJECT, OR REGION OF FLAME: EXTINGUISHED.","YOU ARE NO LONGER ON FIRE."))
			src.KillPathAndGiveUp(1) // Cus they used to keep trying to put someone out, even if they arent on fire. Or are dead.

	if(!src.target || src.target.disposed)
		src.doing_something = 0
		src.target = src.look_for_fire()

	if(src.target)
		src.oldtarget = src.target
		if(src.last_pointed != src.target)
			src.last_pointed = src.target
			src.point(src.target)
		ON_COOLDOWN(src, FIREBOT_SEARCH_COOLDOWN, src.found_cooldown)
		src.frustration = 0
		src.doing_something = 1
		if(IN_RANGE(src,src.target,3))
			spray_at(src.target)
		else
			src.navigate_to(get_turf(src.target), FIREBOT_MOVE_SPEED, max_dist = 30)
			if (!src.path)
				src.KillPathAndGiveUp(1)

/obj/machinery/bot/firebot/proc/look_for_fire()
	if(ON_COOLDOWN(src, FIREBOT_SEARCH_COOLDOWN, src.found_cooldown))
		return
	if(src.extinguish_flags & EXTINGUISH_HOTSPOTS)
		for_by_tcl(H, /obj/hotspot) // First search for burning tiles
			if ((H == src.oldtarget))
				continue
			if(IN_RANGE(src, H, 7))
				if(prob(10))
					if(src.setup_party)
						src.speak(pick("IT IS PARTY TIME.","I AM A FAN OF PARTIES", "PARTIES ARE THE FUTURE"))
					else
						src.speak(pick("I AM GOING TO MURDER THIS FIRE.","KILL ALL FIRES.","I DIDN'T START THIS, BUT I'M GOING TO END IT.","[world.time >= 30 MINUTES ? "TONIGHT" : "TODAY"] A FIRE DIES."))
				return H

	if(src.extinguish_flags & EXTINGUISH_ITEMS)
		for (var/obj/O in by_cat[TR_CAT_BURNING_ITEMS]) // Is anything else on fire?
			if (O == src.oldtarget)
				continue
			if(IN_RANGE(src, O, 7))
				if(prob(10))
					if(src.setup_party)
						src.speak(pick("PARTY SUPPLIES DETECTED. RIGHT ON.","PARTY FAVORS ARE THE BEST FLAVOR.", "[O] PARTY FOUL PROBABILITY: [rand(1, 150)]%. RECTIPARTYING."))
					else
						src.speak(pick("[O] BURN POINT TEMPERATURE EXCEEDED.","[O] DOT BURNING GREATER THAN ZERO EQUALS TRUE.","HOT [pick("ANGRY", "BURNING")] [O] IN MY AREA DETECTED.","[world.time >= 30 MINUTES ? "TONIGHT" : "TODAY"] A FIRE DIES."))
				return O

	if(src.extinguish_flags & EXTINGUISH_MOBS)
		for (var/mob/M in by_cat[TR_CAT_BURNING_MOBS]) // fine I guess we can go extinguish someone
			if (M == src.oldtarget || isdead(M) || !src.valid_target(M))
				continue
			if(IN_RANGE(src, M, 7) && (M.getStatusDuration("burning") || (src.emagged && prob(25))))
				if (src.setup_party)
					src.speak(pick("YOU NEED TO GET DOWN -- ON THE DANCE FLOOR", "PARTY HARDER", "HAPPY BIRTHDAY.", "YOU ARE NOT PARTYING SUFFICIENTLY.", "NOW CORRECTING PARTY DEFICIENCY."))
				else
					src.speak(pick("YOU ARE ON FIRE!", "STOP DROP AND ROLL","THE FIRE IS ATTEMPTING TO FEED FROM YOU! I WILL STOP IT","I WON'T LET YOU BURN AWAY!",5;"Taste the meat, not the heat."))
				return M


/obj/machinery/bot/firebot/DoWhileMoving()
	. = ..()
	if (IN_RANGE(src, src.target, 3) && !ON_COOLDOWN(src, FIREBOT_SPRAY_COOLDOWN, src.spray_cooldown))
		src.frustration = 0
		spray_at(src.target)
		return TRUE

/obj/machinery/bot/firebot/KillPathAndGiveUp(var/give_up)
	. = ..()
	src.last_pointed = null
	if(give_up)
		src.oldtarget = src.target
		src.target = null
		ON_COOLDOWN(src, FIREBOT_SEARCH_COOLDOWN, src.found_cooldown)

//Oh no, we may or may not be emagged! Better hope someone crossing us is on fire!
/obj/machinery/bot/firebot/HasProximity(atom/movable/AM as mob|obj)
	if(!on || stunned)
		return

	if (iscarbon(AM) && ((!ON_COOLDOWN(src, FIREBOT_SPRAY_COOLDOWN, src.spray_cooldown) && src.target == AM) || src.emagged))
		var/mob/living/carbon/hosem = AM
		if(src.emagged && prob(40) || hosem.getStatusDuration("burning"))
			spray_at(AM)

/obj/machinery/bot/firebot/proc/spray_at(atom/target)
	if(!target || !src.on || src.stunned)
		return

	ON_COOLDOWN(src, FIREBOT_SPRAY_COOLDOWN, src.spray_cooldown)
	var/direction = get_dir(src,target)

	var/turf/T = get_turf(target)
	T = get_step(T, direction)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))

	var/list/the_targets = list(T,T1,T2)

	flick("firebot-c", src)
	if (src.setup_party)
		playsound(src.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 75, 1, -3)

	else
		playsound(src.loc, 'sound/effects/spray.ogg', 30, 1, -3)

	for(var/a in 0 to 5)
		var/obj/effects/water/W = new /obj/effects/water
		if(!W) return
		W.set_loc( get_turf(src) )
		var/turf/my_target = pick(the_targets)
		var/datum/reagents/R = new/datum/reagents(15)
		R.add_reagent("water", src.water_amt)
		R.add_reagent("ff-foam", src.foam_amt)
		if (src.setup_party)	// heh
			R.add_reagent("sparkles", 5)
		W.spray_at(my_target, R, 1)

	if (src.emagged && iscarbon(target))
		var/atom/targetTurf = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))

		var/mob/living/carbon/Ctarget = target
		boutput(Ctarget, "<span class='alert'><b>[src] knocks you back!</b></span>")
		Ctarget.changeStatus("weakened", 2 SECONDS)
		Ctarget.throw_at(targetTurf, 200, 4)

	if (iscarbon(src.target)) //Check if this is a mob and we can stop spraying when they are no longer on fire.
		var/mob/living/carbon/C = src.target
		if (!C.getStatusDuration("burning") || isdead(C))
			src.KillPathAndGiveUp(1)
	else
		src.KillPathAndGiveUp(0)

	return

/obj/machinery/bot/firebot/ex_act(severity)
	switch(severity)
		if(1)
			src.explode()
			return
		if(2)
			src.health -= 15
			if (src.health <= 0)
				src.explode()
			return
	return

/obj/machinery/bot/firebot/meteorhit()
	src.explode()
	return

/obj/machinery/bot/firebot/blob_act(var/power)
	if(prob(25 * power / 20))
		src.explode()
	return

/obj/machinery/bot/firebot/gib()
	return src.explode()

/obj/machinery/bot/firebot/explode()
	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	src.visible_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
	playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 40, 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/device/prox_sensor(Tsec)

	new /obj/item/extinguisher(Tsec)

	if (prob(50))
		new /obj/item/parts/robot_parts/arm/left/standard(Tsec)

	var/obj/item/storage/toolbox/emergency/emptybox = new /obj/item/storage/toolbox/emergency(Tsec)
	for(var/obj/item/I in emptybox.contents) //Empty the toolbox so we don't have infinite crowbars or whatever
		qdel(I)

	elecflash(src, radius=1, power=3, exclude_center = 0)
	qdel(src)
	return

/obj/machinery/bot/firebot/proc/toggle_power()
	src.on = !src.on
	src.target = null
	src.oldtarget = null
	src.oldloc = null
	src.path = null
	if(src.cooldowns)
		src.cooldowns -= FIREBOT_SEARCH_COOLDOWN
		src.cooldowns -= FIREBOT_SPRAY_COOLDOWN
	src.icon_state = "firebot[src.on]"
	src.updateUsrDialog()
	return

/obj/machinery/bot/firebot/proc/valid_target(mob/M)
	return TRUE

/obj/machinery/bot/firebot/firebrand
	name = "Firebrand Firebot"
	desc = "A little friendly-fire-fighting robot! He looks so darn evil."
	extinguish_flags = EXTINGUISH_MOBS
	water_amt = 0
	foam_amt = 10

/obj/machinery/bot/firebot/firebrand/valid_target(mob/M)
	return istype(M.get_id(), /obj/item/card/id/syndicate)

/*
 *	Firebot construction
 */

/obj/item/storage/toolbox/emergency/attackby(var/obj/item/parts/robot_parts/P, mob/user as mob)
	if (!istype(P, /obj/item/parts/robot_parts/arm/))
		..()
		return

	if(src.contents.len >= 1)
		boutput(user, "<span class='alert'>You need to empty [src] out first!</span>")
		return

	var/obj/item/toolbox_arm/B = new /obj/item/toolbox_arm
	B.set_loc(user)
	user.u_equip(P)
	user.put_in_hand_or_drop(B)
	boutput(user, "You add the arm to the empty toolbox.  It's a little awkward.")
	qdel(P)
	qdel(src)

/obj/item/toolbox_arm/attackby(obj/item/W, mob/user)
	if ((istype(W, /obj/item/extinguisher)) && (!src.extinguisher))
		src.extinguisher = 1
		boutput(user, "You add the fire extinguisher to [src]!")
		src.name = "Toolbox/robot arm/fire extinguisher assembly"
		src.icon_state = "toolbox_arm_ext"
		qdel(W)

	else if ((istype(W, /obj/item/device/prox_sensor)) && (src.extinguisher))
		boutput(user, "You complete the Firebot! Beep boop.")
		var/obj/machinery/bot/firebot/S = new /obj/machinery/bot/firebot
		S.set_loc(get_turf(src))
		S.name = src.created_name
		qdel(W)
		qdel(src)

	else if (istype(W, /obj/item/pen))
		var/t = input(user, "Enter new robot name", src.name, src.created_name) as text
		if(t && t != src.name && t != src.created_name)
			phrase_log.log_phrase("bot-fire", t)
		t = strip_html(replacetext(t, "'",""))
		t = copytext(t, 1, 45)
		if (!t)
			return
		if (!in_interact_range(src, user) && src.loc != user)
			return

		src.created_name = t

#undef FIREBOT_MOVE_SPEED
