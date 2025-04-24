// Mars Outpost Area II - Electric Boogaloo
// contains: mars area remake stuff
//           old mars stuff (moved from AphsStuff.dm)


// Mars Turfs

/turf/unsimulated/mars
	icon = 'icons/misc/mars_outpost.dmi'
	name = "Mars"
	desc = "Get your ass there."
	icon_state = "placeholder"
	fullbright = 0
	temperature = 220
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000
	pathable = 0
	mat_changename = 0
	mat_changedesc = 0
	oxygen = 0.005
	nitrogen = 0.01
	carbon_dioxide = 0.33
	intact = 0

	// Code borrowed from Forum_account's Turf Edges

	var/edge_weight = 1
	var/has_edges = 0
	var/randomized = 1

	proc/__needs_edge(var/turf/unsimulated/mars/t)
		if(!t) return 0
		if(istype(t, type)) return 0
		if(t.edge_weight > src.edge_weight) return 0
		return 1


	proc/__add_edge(d)
		var/image/i = image('icons/misc/mars_outpost.dmi', icon_state+"-e", layer = TURF_LAYER + 0.01 * edge_weight, dir = d)

		if(d & NORTH) i.pixel_y = 32
		if(d & SOUTH) i.pixel_y = -32
		if(d & EAST) i.pixel_x = 32
		if(d & WEST) i.pixel_x = -32

		src.overlays += i

	proc/generate_edges()

		if(src.has_edges) return

		var/north = __needs_edge(locate(x, y + 1, z))
		var/south = __needs_edge(locate(x, y - 1, z))
		var/east = __needs_edge(locate(x + 1, y, z))
		var/west = __needs_edge(locate(x - 1, y, z))

		if(north) __add_edge(NORTH)
		if(north && east) __add_edge(NORTHEAST)
		if(north && west) __add_edge(NORTHWEST)

		if(south) __add_edge(SOUTH)
		if(south && east) __add_edge(SOUTHEAST)
		if(south && west) __add_edge(SOUTHWEST)

		if(east) __add_edge(EAST)
		if(west) __add_edge(WEST)

		src.has_edges = 1

	proc/clear_edges()

		if(!has_edges) return

		src.overlays = null
		src.has_edges = 0


	Entered(mob/living/carbon/M as mob )
		..()
		if(ishuman(M))
			SPAWN(0.8)
				var/image/F = image('icons/misc/mars_outpost.dmi', icon_state = "footprint", dir = M.dir)
				src.overlays += F
				sleep(20 SECONDS)
				src.overlays -= F

	ex_act(severity)
		switch(severity)
			if(3)
				src.icon_state = "placeholder-ex1"
				return
			if(2)
				src.icon_state = "placeholder-ex2"
				return
			if(1)
				src.icon_state = "placeholder-ex3"
				return
		return

	New()
		..()
		if(!src.randomized) return
		src.generate_edges()
		if(prob(30))
			src.set_dir(pick(NORTH,SOUTH,EAST,WEST))
		if(prob(1))
			new /obj/shrub/redweed(src)
	t1
		edge_weight = 0
		icon_state = "t1"
	t2
		edge_weight = 1
		icon_state = "t2"
	t3
		edge_weight = 2
		icon_state = "t3"
	t4
		edge_weight = 3
		icon_state = "t4"

/turf/unsimulated/mars/sets
	randomized = 0

/turf/unsimulated/mars/sets/tarmac
	name = "tarmac"
	icon_state = "marshighw1"

// Areas

/area/mars
	name = "Mars"
	icon = 'icons/misc/mars_outpost.dmi'
	icon_state = "area"
	irradiated = 1
	permarads = 1
	ambient_light = rgb(255*0.9, 211*0.9, 183*0.9)
	filler_turf = "/turf/unsimulated/mars"


// """Foliage"""

/obj/shrub/redweed
	name = "red weed"
	icon = 'icons/misc/mars_outpost.dmi'
	icon_state = "redweed1"


// Kingsway Systems

/obj/fakeobject/robot/servotron
	name = "servotron statue"
	desc = "A statue of Kingsway Systems' Servotron"
	icon = 'icons/misc/mars_outpost.dmi'
	icon_state = "statue_robot"
	anchored = ANCHORED
	density = 1

/obj/fakeobject/robot/servotron/old
	name = "servotron statue"
	desc = "A statue of Kingsway Systems' Servotron"
	icon = 'icons/misc/mars_outpost.dmi'
	icon_state = "statue_oldrobot"
	anchored = ANCHORED
	density = 1

/obj/fakeobject/robot/servotron/older
	name = "servotron statue"
	desc = "A statue of Kingsway Systems' Servotron"
	icon = 'icons/misc/mars_outpost.dmi'
	icon_state = "statue_olderrobot"
	anchored = ANCHORED
	density = 1


/obj/fakeobject/robotpedestal
	name = "pedestal"
	icon = 'icons/misc/mars_outpost.dmi'
	icon_state = "statue_pedestal"
	anchored = ANCHORED
	density = 1


/obj/fakeobject/robotarm
	name = "robot arm"
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "marsfactory_arm"
	anchored = ANCHORED
	density = 1
	pixel_x = -22
	pixel_y = 5
	layer = EFFECTS_LAYER_UNDER_1


/obj/curiosity
	name = "dusty old rover"
	icon = 'icons/misc/mars_outpost.dmi'
	icon_state = "curiosity"
	density = 1
	var/has_beeped = 0

	attack_hand(mob/user)
		if(has_beeped)
			return ..()
		else
			user.visible_message("[user] presses one of the old rover's buttons.", "You press one of the rover's buttons.")
			playsound(src.loc, 'sound/misc/curiosity_beep.ogg', 50, 1)
			sleep(1 SECOND)
			src.visible_message("<b>[src]</b> beeps out a little tune.")



// LEGACY STUFF
// Abandon hope all ye who cross this line

/turf/unsimulated/floor/setpieces/martian
	name = "martian dust"
	desc = "Someone would've probably paid big money to get a sample of this fifty years ago."
	icon = 'icons/turf/floors.dmi'
	icon_state = "mars1"
	carbon_dioxide = 500
	nitrogen = 0
	oxygen = 0
	temperature = 100
	fullbright = 0
	var/rocks = 1

	New()
		..()
		if(src.rocks)
			icon_state = "[pick("mars1","mars1","mars1","mars2","mars3")]"

/turf/unsimulated/floor/setpieces/martian/cliff
	icon_state = "mars_cliff1"
	density = 1
	rocks = 0

/turf/unsimulated/floor/setpieces/martian/highway
	icon_state = "marshighw1"
	desc = "highway"
	rocks = 0

/turf/unsimulated/wall/setpieces/martian
	name = "martian rock"
	desc = "Hey, it's not red at all!"
	icon = 'icons/turf/walls.dmi'
	icon_state = "mars"
	gas_impermeable = 1
	opacity = 1
	density = 1
	fullbright = 0


/obj/fakeobject/mule_xl
	name = "Mulebot XL"
	desc = "If you thought getting run over by a mulebot was bad, get a load of his big brother! No pun intended."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "mule-xl"
	pixel_x = -16

/obj/fakeobject/mars_billboard
	name = "Billboard"
	desc = "A billboard for some backwater planetary outpost. How old is this?"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "mars_sign1"
	anchored = ANCHORED
	density = 0
	pixel_x = -32

/obj/decal/cleanable/dirt/mars
	name = "dirt"
	desc = "That isn't any old pile of dirt, it's martian dirt!"
	density = 0
	anchored = ANCHORED
	icon = 'icons/misc/worlds.dmi'
	icon_state = "mars_dirt"

// old/legacy content starts here //

/obj/item/clothing/suit/armor/mars
	name = "ME-3 Suit"
	desc = "A suit designed to withstand intense dust storms."
	icon_state = "mars_blue"
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
	item_state = "mars_blue"
	c_flags = SPACEWEAR
	protective_temperature = 700

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("heatprot", 80)
		setProperty("chemprot", 20)

/obj/item/clothing/head/helmet/mars
	name = "ME-3 Helmet "
	desc = "A suit designed to preserve the user's visibility during intense dust storms."
	icon_state = "mars"
	item_state = "mars"
	c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH
	see_face = TRUE

/obj/critter/marsrobot
	name = "Inactive Robot"
	desc = "It looks like it hasn't been in service for decades."
	icon = 'icons/mob/critter/robotic/mars_bot.dmi'
	icon_state = "mars_bot"
	death_text = "%src% collapses!"
	density = 1
	health = 55
	aggressive = 1
	defensive = 1
	wanderer = 0
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	firevuln = 1
	brutevuln = 1
	var/active = 0
	var/startup = 1

	New()
		..()
		icon_state = "mars_bot-0"

	seek_target()
		if(active)
			src.anchored = UNANCHORED
			for (var/mob/living/C in hearers(src.seekrange,src))
				if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
				if (iscarbon(C) && !src.atkcarbon) continue
				if (issilicon(C) && !src.atksilicon) continue
				if (C.health < 0) continue
				if (C in src.friends) continue
				if (C.name == src.attacker) src.attack = 1
				if (iscarbon(C) && src.atkcarbon) src.attack = 1
				if (issilicon(C) && src.atksilicon) src.attack = 1

				if (src.attack)
					src.target = C
					src.oldtarget_name = C.name
					if(startup)
						src.visible_message(SPAN_COMBAT("The <b>[src]</b> suddenly turns on!"))
						name = "malfunctioning robot"
						src.speak("Lev##LLl 7 SEV-s-E infraAAAAAaction @leRT??!")
						src.visible_message("The <b>[src]</b> points at [C.name]!")
						playsound(src.loc, 'sound/voice/screams/robot_scream.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						startup = 0
						wanderer = 1
					src.visible_message(SPAN_ALERT("The <b>[src]</b> charges at [C:name]!"))
					src.speak(pick("DooN'T Wor##y I'M hERE!!!","LawwSS UpdAA&$.A.!!.!","CANIHELPYO&£%SIR","REsREACH!!!!!","NATAS&$%LIAHLLA ERROR CODE #736"))
					playsound(src.loc, 'sound/machines/glitch3.ogg', 50, 1)
					icon_state = "mars_bot"
					src.task = "chasing"
					break
				else
					continue

	ChaseAttack(mob/M)
		src.visible_message(SPAN_COMBAT("The <B>[src]</B> launches itself towards [M]!"))
		if (prob(20)) M.changeStatus("stunned", 2 SECONDS)
		random_brute_damage(M, rand(2,5),1)

	CritterAttack(mob/M)
		src.attacking = 1
		src.visible_message(SPAN_COMBAT("The <B>[src]</B> slams itself against [src.target]!"))
		random_brute_damage(src.target, rand(7,17), 1)
		SPAWN(1 SECOND)
			src.attacking = 0


	Move()
		. = ..()
		playsound(src.loc, 'sound/effects/airbridge_dpl.ogg', 30, 10, -2)


	proc/speak(var/message)
		for(var/mob/O in hearers(src, null))
			boutput(O, SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"[message]\""))
		return

	attackby(obj/item/W, mob/living/user)
		if(active) ..()

	attack_hand(var/mob/user)
		if(active) ..()

	CritterDeath()
		if (!src.alive) return
		..()
		playsound(src.loc, 'sound/voice/screams/robot_scream.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
		speak("aaaaaaalkaAAAA##AAAAAAAAAAAAAAAAA'ERRAAAAAAAA!!!")

/obj/mars_roverpuzzle
	name = "rover frame"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "rover_puzzle_base"
	desc = "It looks like this rover was never finished."
	density = 1
	anchored = ANCHORED
	var/wheel = 0
	var/oxy = 0
	var/battery = 0
	var/glass = 0
	var/motherboard = 0

	attackby(obj/item/P, mob/user)
		if (istype(P, /obj/item/mars_roverpart))
			if ((istype(P, /obj/item/mars_roverpart/wheel))&&(!wheel))
				boutput(user, SPAN_NOTICE("You attach the wheel to the rover's chassis."))
				overlays += image('icons/misc/worlds.dmi', "rover_puzzle_wheel")
				wheel = 1
			if ((istype(P, /obj/item/mars_roverpart/oxy))&&(!oxy))
				boutput(user, SPAN_NOTICE("You connect the life support module to the rover."))
				overlays += image('icons/misc/worlds.dmi', "rover_puzzle_oxy")
				oxy = 1
			if ((istype(P, /obj/item/mars_roverpart/glass))&&(!glass))
				boutput(user, SPAN_NOTICE("You attach the glass to the rover."))
				overlays += image('icons/misc/worlds.dmi', "rover_puzzle_window")
				glass = 1
			if ((istype(P, /obj/item/mars_roverpart/battery))&&(!battery))
				boutput(user, SPAN_NOTICE("You wire the battery to the rover."))
				overlays += image('icons/misc/worlds.dmi', "rover_puzzle_cell")
				battery = 1
			if ((istype(P, /obj/item/mars_roverpart/motherboard))&&(!motherboard))
				boutput(user, SPAN_NOTICE("You wire the motherboard to the rover."))
				motherboard = 1
			playsound(user, 'sound/items/Deconstruct.ogg', 65, TRUE)
			qdel(P)
			if((wheel)&&(oxy)&&(battery)&&(glass)&&(motherboard))
				var/obj/vehicle/marsrover/R = new /obj/vehicle/marsrover(loc)
				R.set_dir(WEST)
				playsound(src.loc, 'sound/machines/rev_engine.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("The rover has been completed!"))
				qdel(src)

/obj/item/mars_roverpart
	icon = 'icons/misc/worlds.dmi'

	wheel
		name = "wheel"
		icon_state = "rover_puzzle_wheelitem"
		desc = "A wheel for some kind of vehicle."
	oxy
		name = "filter"
		icon_state = "rover_puzzle_oxyitem"
		desc = "Some kind of filter designed to keep dust from getting into a chamber."
	glass
		name = "glass"
		icon_state = "rover_puzzle_glassitem"
		desc = "It looks pretty strong."
	battery
		name = "rover battery"
		icon_state = "rover_puzzle_batteryitem"
		desc = "A battery designed for rovers. I don't think it's safe to poke around with this thing."

	motherboard
		name = "rover motherboard"
		icon_state = "rover_puzzle_motherboarditem"
		desc = "The motherboard of a rover, it looks pretty fancy!"
		var/pickedup = 0

		pickup(mob/user)
			..()
			if(!pickedup)
				boutput(user, SPAN_ALERT("Uh oh."))
				for(var/obj/critter/marsrobot/M in oview(4,src))
					M.active = 1
					M.seek_target()
				pickedup = 1


TYPEINFO(/obj/vehicle/marsrover)
	mats = 8

/obj/vehicle/marsrover
	name = "Rover"
	desc = "A rover designed to let researchers explore hazardous planets safely and efficiently. It looks pretty old."
	icon_state = "marsrover"
	rider_visible = 0
	layer = MOB_LAYER + 1
	sealed_cabin = 1

/obj/vehicle/marsrover/proc/update()
	if(rider)
		icon_state = "marsrover2"
	else
		icon_state = "marsrover"

/obj/vehicle/marsrover/eject_rider(var/crashed, var/selfdismount, ejectall=TRUE)
	var/mob/rider = src.rider
	..()
	rider.pixel_y = 0
	walk(src, 0)

	for (var/obj/item/I in src)
		I.set_loc(get_turf(src))

	if(crashed)
		if(crashed == 2)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
		boutput(rider, SPAN_COMBAT("<B>You are flung over the [src]'s handlebars!</B>"))
		rider.changeStatus("stunned", 8 SECONDS)
		rider.changeStatus("knockdown", 5 SECONDS)
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message(SPAN_COMBAT("<B>[rider] is flung over the [src]'s handlebars!</B>"), 1)
		var/turf/target = get_edge_target_turf(src, src.dir)
		rider.throw_at(target, 5, 1)
		rider.buckled = null
		rider = null

		update()
		return
	if(selfdismount)
		boutput(rider, SPAN_NOTICE("You dismount from the [src]."))
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<B>[rider]</B> dismounts from the [src].", 1)
	rider.buckled = null
	rider = null
	update()
	return

/obj/vehicle/marsrover/do_special_on_relay(mob/user as mob, dir)
	icon_state = "marsrover2"

/obj/vehicle/marsrover/MouseDrop_T(mob/living/carbon/human/target, mob/user)
	if (rider || !istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || BOUNDS_DIST(user, src) > 0 || is_incapacitated(user) || isAI(user))
		return

	var/msg

	if(target == user && !user.stat)	// if drop self, then climbed in
		msg = "[user.name] climbs onto the [src]."
		boutput(user, SPAN_NOTICE("You climb onto the [src]."))
	else if(target != user && !user.restrained())
		msg = "[user.name] helps [target.name] onto the [src]!"
		boutput(user, SPAN_NOTICE("You help [target.name] onto the [src]!"))
	else
		return

	for (var/obj/item/I in src)
		I.set_loc(get_turf(src))

	target.set_loc(src)
	rider = target
	rider.pixel_x = 0
	rider.pixel_y = 5
	if(rider.restrained() || rider.stat)
		rider.buckled = src

	for (var/mob/C in AIviewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)

	update()
	return

/obj/vehicle/marsrover/Click()
	if(usr != rider)
		..()
		return
	if(!is_incapacitated(usr))
		eject_rider(0, 1)
	return

/obj/vehicle/marsrover/attack_hand(mob/living/carbon/human/M)
	if(!M || !rider)
		..()
		return
	switch(M.a_intent)
		if("harm", "disarm")
			if(prob(60))
				playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
				src.visible_message(SPAN_COMBAT("<B>[M] has shoved [rider] off of the [src]!</B>"))
				rider.changeStatus("knockdown", 2 SECONDS)
				eject_rider()
			else
				playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 25, 1, -1)
				src.visible_message(SPAN_COMBAT("<B>[M] has attempted to shove [rider] off of the [src]!</B>"))
	return

/obj/vehicle/marsrover/disposing()
	if(rider)
		boutput(rider, SPAN_COMBAT("<B>Your rover is destroyed!</B>"))
		eject_rider()
	..()
	return

/area/marsoutpost
	name = "Abandoned Outpost"
	icon_state = "red"
	sound_group = "mars"
	sound_loop = 'sound/ambience/loop/Mars_Interior.ogg'
	sound_loop_vol = 60
	area_parallax_render_source_group = /datum/parallax_render_source_group/area/mars
	occlude_foreground_parallax_layers = TRUE

/area/marsoutpost/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_AREA_PROCESS)

/area/marsoutpost/disposing()
	STOP_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	. = ..()

/area/marsoutpost/area_process()
	if(prob(20))
		src.sound_fx_2 = pick(
			'sound/ambience/nature/Mars_Rockslide1.ogg',\
			'sound/ambience/industrial/MarsFacility_MovingEquipment.ogg',\
			'sound/ambience/nature/Mars_Rockslide2.ogg',\
			'sound/ambience/industrial/MarsFacility_Glitchy.ogg')

		for(var/mob/living/carbon/human/H in src)
			H.client?.playAmbience(src, AMBIENCE_FX_2, 60)

/area/marsoutpost/duststorm
	name = "Barren Planet"
	icon_state = "yellow"
	occlude_foreground_parallax_layers = FALSE

	Entered(atom/movable/O)
		..()
		if (ishuman(O))
			var/mob/living/jerk = O
			if (!isdead(jerk))
				if((istype(jerk:wear_suit, /obj/item/clothing/suit/armor/mars))&&(istype(jerk:head, /obj/item/clothing/head/helmet/mars))) return
				random_brute_damage(jerk, 100)
				jerk.changeStatus("knockdown", 40 SECONDS)
				step(jerk,EAST)
				if(prob(50))
					playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_2.ogg', 50, 1)
					boutput(jerk, pick("Dust gets caught in your eyes!","The wind blows you off course!","Debris pierces through your skin!"))



/area/marsoutpost/vault
	name = "Abandoned Vault"
	icon_state = "red"

/obj/critter/gunbot/heavy
	name = "security robot"
	desc = "A 2030's-era security robot. Uh oh."
	icon_state = "gunbot"
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atksilicon = 1
	var/overheat = 0
	var/datum/projectile/my_bullet = new/datum/projectile/bullet/revolver_38

	Shoot()
		if(overheat < 10)
			overheat ++
			..()

	proc/speak(var/message)
		if((!alive) || (!message))
			return

		var/fontSize = 2
		var/fontIncreasing = 1
		var/fontSizeMax = 2
		var/fontSizeMin = -2
		var/messageLen = length(message)
		var/processedMessage = ""

		for (var/i = 1, i <= messageLen, i++)
			processedMessage += "<font size=[fontSize]>[copytext(message, i, i+1)]</font>"
			if (fontIncreasing)
				fontSize = min(fontSize+1, fontSizeMax)
				if (fontSize >= fontSizeMax)
					fontIncreasing = 0
			else
				fontSize = max(fontSize-1, fontSizeMin)
				if (fontSize <= fontSizeMin)
					fontIncreasing = 1
			if(prob(10))
				processedMessage += pick("%","##A","-","- - -","ERROR")

		for(var/mob/O in hearers(src, null))
			O.show_message(SPAN_SAY("[SPAN_NAME("[src]")] blares, \"<B>[processedMessage]</B>\""), 2)

		return


	seek_target()
		src.anchored = UNANCHORED
		if(overheat == 10)
			speak("WARNING : OVERHEATING")
			sleep(5 SECONDS)
			overheat = 0
		else
			for (var/mob/living/C in hearers(src.seekrange,src))
				if (!src.alive) break
				if (C.health < 0) continue
				if (C.name == src.attacker) src.attack = 1
				if (iscarbon(C) && src.atkcarbon) src.attack = 1
				if (issilicon(C) && src.atksilicon) src.attack = 1

				if (src.attack)

					src.target = C
					src.oldtarget_name = C.name
					src.visible_message(SPAN_COMBAT("<b>[src]</b> rapidly fires at [src.target]!"))


					playsound(src.loc, 'sound/weapons/ak47shot.ogg', 50, 1)
					var/tturf = get_turf(target)
					SPAWN(0.2 SECONDS)
						Shoot(tturf, src.loc, src)
						src.pixel_x += rand(-3,3)
						src.pixel_y += rand(-3,3)
					if(prob(55))
						speak(pick("SECURITY OPERATION IN PROGRESS.","WARNING - YOU ARE IN A SECURITY ZONE.","ALERT - ALL OUTPOST PERSONNEL ARE TO MOVE TO A SAFE ZONE.","WARNING: THREAT RECOGNIZED AS NANOTRASEN, ESPONIAGE DETECTED","THIS IS FOR THE FREE MARKET","NANOTRASEN BETRAYED YOU."))
						var/glitchsound = pick('sound/machines/romhack1.ogg', 'sound/machines/romhack2.ogg', 'sound/machines/romhack3.ogg','sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/machines/glitch4.ogg','sound/machines/glitch5.ogg')
						playsound(src.loc, glitchsound, 50, 1)
					if(prob(75))
						SPAWN(0) step_to(src,target)
					src.attack = 0
					return
				else continue
		task = "thinking"

	Shoot(var/target, var/start, var/user, var/bullet = 0)
		if(target == start)
			return
		if (!start) //Wire: fix for Cannot read null.y (start was null somehow)
			return

		shoot_projectile_ST_pixel_spread(src, my_bullet, target)

/obj/machinery/computer/mars_vault
	name = "Vault Console"
	desc = "A very old computer that controls the vault."
	icon_state = "old"
	pixel_y = 8
	var/triggered = 0

	attack_hand(mob/user)
		if (..() || (status & (NOPOWER|BROKEN)))
			return

		src.add_dialog(user)
		add_fingerprint(user)

		var/dat = "<center><h4>Vault Computer</h4></center>"
		if(triggered)
			dat += "<center><font size = 20>VAULT UNLOCKED</font></center><br>"

		else
			dat += "<center><a href='byond://?src=\ref[src];unlock=1'>Unlock Vault</a></center>"
		user.Browse("<head><title>Vault Computer</title></head>[dat]", "window=tourconsole;size=302x245")
		onclose(user, "vaultcomputer")
		return

	Topic(href, href_list)
		if(..())
			return
		src.add_dialog(usr)
		src.add_fingerprint(usr)

		if (href_list["unlock"])
			if(!triggered)
				triggered = 1
				for(var/area/marsoutpost/vault/V in world)
					V.overlays += image(icon = 'icons/effects/alert.dmi', icon_state = "blue", layer = EFFECTS_LAYER_1)
					LAGCHECK(LAG_LOW)
				for_by_tcl(P, /obj/machinery/door/poddoor)
					if (P.id == "mars_vault")
						SPAWN(0)
							P.open()
				for_by_tcl(M, /obj/item/storage/secure/ssafe/marsvault)
					M.disabled = 0

				if (istype(get_area(src), /area/marsoutpost/vault))
					for (var/mob/living/L in range(3, src))
						if (!isintangible(L))
							L.unlock_medal("Where are the Ghosts?", TRUE)

				playsound(src.loc, 'sound/machines/engine_alert1.ogg', 50, 1)


		src.updateUsrDialog()
		return

/obj/item/device/audio_log/mars
		continuous = 0
		audiolog_messages = list("*Heavy breathing*",
								"ALERT: THE EMERGENCY ROCKET WILL ARRIVE IN FIVE MINUTES.",
								"Come on, wh-have to get out of here!",
								"I can't.. *cough*",
								"Please! We can't just stay here, we are the only ones left who-",
								"It's too late for me, you sti-*cough*-have a chance to escape with it.",
								"Take the r-ro-rover, it's yo-u-*cough* *cough* ... . .   .",
								"*Psshhh*")
		audiolog_speakers = list("Male Scientist",
								"Computerized Voice",
								"Female Scientist",
								"Male Scientist",
								"Female Scientist",
								"Male Scientist",
								"Male Scientist",
								"Airlock")
