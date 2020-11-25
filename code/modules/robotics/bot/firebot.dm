//Firebot
//Firebot assembly

/obj/machinery/bot/firebot
	name = "Firebot"
	desc = "A little fire-fighting robot!  He looks so darn chipper."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "firebot0"
	event_handler_flags = USE_PROXIMITY | USE_FLUID_ENTER | USE_CANPASS
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = 0
	req_access = list(access_engineering_atmos)
	on = 1
	health = 20
	var/stunned = 0 //It can be stunned by tasers. Delicate circuits.
	locked = 1
	var/frustration = 0
	var/list/path = null
	var/obj/hotspot/target = null
	var/obj/hotspot/oldtarget = null
	var/oldloc = null
	var/last_found = 0
	var/last_spray = 0
	var/setup_party = 0
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
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = TABLEPASS
	var/extinguisher = 0 //Is the extinguisher added?
	var/created_name = "Firebot"

/obj/machinery/bot/firebot/New()
	..()
	SPAWN_DBG (5)
		if (src)
			// Firebots are used in multiple department, so I guess they get all-access instead of only engineering.
			src.botcard = new /obj/item/card/id(src)
			src.botcard.access = get_access(src.access_lookup)
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

	if (user.client.tooltipHolder)
		user.client.tooltipHolder.showClickTip(src, list(
			"params" = params,
			"title" = "Firebot v1.0 controls",
			"content" = dat,
		))

/obj/machinery/bot/firebot/attack_hand(mob/user as mob, params)
	var/dat
	dat += "<TT><B>Automatic Fire-Fighting Unit v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A><BR>"

//	dat += "<br>Behaviour controls are [src.locked ? "locked" : "unlocked"]<hr>"
//	if(!src.locked)
//To-Do: Behavior control stuff to go with ~fire patrols~

	if (user.client.tooltipHolder)
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
		SPAWN_DBG(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("<span class='alert'><B>[src] buzzes oddly!</B></span>", 1)
		flick("firebot_spark", src)
		src.target = null
		src.last_found = world.time
		src.anchored = 0
		src.emagged = 1
		src.on = 1
		src.icon_state = "firebot[src.on]"
		logTheThing("station", user, null, "emagged a [src] at [log_loc(src)].")
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
		src.target = null
		src.last_found = world.time
		src.anchored = 0
		src.emagged = 1
		src.on = 1
		src.icon_state = "firebot[src.on]"
	else
		src.explode()
	return

/obj/machinery/bot/firebot/attackby(obj/item/W as obj, mob/user as mob)
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
	if(!src.on)
		src.stunned = 0
		return

	if(src.stunned)
		src.icon_state = "firebota"
		src.stunned--

		src.oldtarget = src.target
		src.target = null

		if(src.stunned <= 0)
			src.icon_state = "firebot[src.on]"
			src.stunned = 0
		return

	if(src.frustration > 8)
		src.oldtarget = src.target
		src.target = null
		//src.currently_healing = 0
		src.last_found = world.time
		src.path = null
		src.frustration = 0

	if(!src.target)
		for (var/obj/hotspot/H in view(7,src))
			if ((H == src.oldtarget) && (world.time < src.last_found + 80))
				continue

			src.target = H
			src.oldtarget = H
			src.last_found = world.time
			src.frustration = 0
			if(prob(10))
				SPAWN_DBG(0)
					src.speak( src.setup_party ? pick("IT IS PARTY TIME.","I AM A FAN OF PARTIES", "PARTIES ARE THE FUTURE") : pick("I AM GOING TO MURDER THIS FIRE.","KILL ALL FIRES.","I DIDN'T START THIS, BUT I'M GOING TO END IT.","A fire is going to die tonight.") )
			break

		if (!src.target)
			for (var/mob/living/carbon/burningMob in view(7, src))
				if (burningMob == src.oldtarget && (world.time < src.last_found + 80))
					continue

				if (isdead(burningMob))
					continue

				if (burningMob.getStatusDuration("burning") || (src.emagged && prob(25)))
					src.target = burningMob
					src.oldtarget = burningMob
					src.last_found = world.time
					src.frustration = 0
					src.visible_message("<b>[src]</b> points at [burningMob.name]!")
					if (src.setup_party)
						src.speak(pick("YOU NEED TO GET DOWN -- ON THE DANCE FLOOR", "PARTY HARDER", "HAPPY BIRTHDAY.", "YOU ARE NOT PARTYING SUFFICIENTLY.", "NOW CORRECTING PARTY DEFICIENCY."))
					else
						src.speak(pick("YOU ARE ON FIRE!", "STOP DROP AND ROLL","THE FIRE IS ATTEMPTING TO FEED FROM YOU! I WILL STOP IT","I WON'T LET YOU BURN AWAY!",5;"Taste the meat, not the heat."))
					break

	if(src.target && (get_dist(src,src.target) <= 2))
		if(world.time > src.last_spray + 30)
			src.frustration = 0
			spray_at(src.target)
		if (iscarbon(src.target)) //Check if this is a mob and we can stop spraying when they are no longer on fire.
			var/mob/living/carbon/C = src.target
			if (!C.getStatusDuration("burning") || isdead(C))
				src.frustration = INFINITY
		return

	else if(src.target && src.path && src.path.len && (get_dist(src.target,src.path[src.path.len]) > 2))
		src.path = new()
//		src.currently_healing = 0
		src.last_found = world.time

	if(src.target && (!src.path || !src.path.len) && (get_dist(src,src.target) > 1))
		SPAWN_DBG(0)
			if (!isturf(src.loc))
				return
			src.path = AStar(get_turf(src), get_turf(src.target), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, adjacent_param = botcard)
			if (!src.path)
				src.frustration += 4
		return

	if(src.path && src.path.len && src.target)
		step_to(src, src.path[1])
		src.path -= src.path[1]
		SPAWN_DBG(0.3 SECONDS)
			if(src.path && src.path.len)
				step_to(src, src.path[1])
				src.path -= src.path[1]

	if(src.path && src.path.len > 8 && src.target)
		src.frustration++

	return

//Oh no we're emagged!! Nobody better try to cross us!
/obj/machinery/bot/firebot/HasProximity(atom/movable/AM as mob|obj)
	if(!on || !emagged || stunned)
		return

	if (iscarbon(AM) && prob(40))
		spray_at(AM)

	return

/obj/machinery/bot/firebot/proc/spray_at(atom/target)
	if(!target || !src.on || src.stunned)
		return

	src.last_spray = world.time
	var/direction = get_dir(src,target)

	var/turf/T = get_turf(target)
	T = get_step(T, direction)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))

	var/list/the_targets = list(T,T1,T2)

	flick("firebot-c", src)
	if (src.setup_party)
		playsound(src.loc, "sound/musical_instruments/Bikehorn_1.ogg", 75, 1, -3)

	else
		playsound(src.loc, "sound/effects/spray.ogg", 75, 1, -3)

	for(var/a=0, a<5, a++)
		//SPAWN_DBG(0)
		var/obj/effects/water/W = unpool(/obj/effects/water)
		if(!W) return
		W.set_loc( get_turf(src) )
		var/turf/my_target = pick(the_targets)
		var/datum/reagents/R = new/datum/reagents(15)
		R.add_reagent("water", 2)
		R.add_reagent("ff-foam", 8)
		if (src.setup_party)	// heh
			R.add_reagent("glitter_harmless", 5)
		W.spray_at(my_target, R)

	if (src.emagged && iscarbon(target))
		var/atom/targetTurf = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))

		var/mob/living/carbon/Ctarget = target
		boutput(Ctarget, "<span class='alert'><b>[src] knocks you back!</b></span>")
		Ctarget.changeStatus("weakened", 2 SECONDS)
		Ctarget.throw_at(targetTurf, 200, 4)

	return

/obj/machinery/bot/firebot/ex_act(severity)
	switch(severity)
		if(1.0)
			src.explode()
			return
		if(2.0)
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
	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/device/prox_sensor(Tsec)

	new /obj/item/extinguisher(Tsec)

	if (prob(50))
		new /obj/item/parts/robot_parts/arm/left(Tsec)

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
	src.last_found = 0
	src.last_spray = 0
	src.icon_state = "firebot[src.on]"
	src.updateUsrDialog()
	return

/obj/machinery/bot/firebot/Bumped(M as mob|obj)
	SPAWN_DBG(0)
		var/turf/T = get_turf(src)
		M:set_loc(T)


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

/obj/item/toolbox_arm/attackby(obj/item/W as obj, mob/user as mob)
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
		t = strip_html(replacetext(t, "'",""))
		t = copytext(t, 1, 45)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t
