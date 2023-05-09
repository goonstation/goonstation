/*
Contains:
-Vehicle defines
-Vehicle parent
-Segway
-Floor buffer
-Clown car
-Rideable cats
-Admin bus
-Forklift
*/

//------------------ Vehicle Defines --------------------///
#define MINIMUM_EFFECTIVE_DELAY 0.001 //absolute maximum speed for vehicles (lower is faster), do not set to 0 or division by 0 will happen

//////////////////////////////// Vehicle parent ///////////////////////////////////////
ABSTRACT_TYPE(/obj/vehicle)
/obj/vehicle
	name = "vehicle"
	icon = 'icons/obj/vehicles.dmi'
	density = TRUE
	var/mob/living/rider = null //! Rider is basically the "driver" of the vehicle
	var/in_bump = FALSE //! Sanity variable to prevent the vehicle from crashing multiple times due to a single collision
	var/sealed_cabin = FALSE //! Does the vehicle have air conditioning? (check /datum/lifeprocess/bodytemp in bodytemp.dm for details)
	var/rider_visible =	TRUE //! Can we see the driver from outside of the vehicle? (used for overlays)
	var/list/ability_buttons = null //! Storage for the ability buttons after initialization
	var/list/ability_buttons_to_initialize = null //! List of types of ability buttons to be initialized
	var/can_eject_items = FALSE //! See /mob/proc/drop_item() in mob.dm and /atom/movable/proc/throw_at in throwing.dm
	var/attacks_fast_eject = TRUE //! Whether any attack with an item that has a force value will immediately eject the rider (only works if rider_visible is true)
	layer = MOB_LAYER
	var/delay = 2 //! Speed, lower is faster, minimum of MINIMUM_EFFECTIVE_DELAY
	var/booster_upgrade = FALSE //! Do we go through space?
	var/booster_image = null //! What overlay icon do we use for the booster upgrade? (we have to initialize this in New)
	var/emagged = FALSE
	var/health = null
	var/health_max = null

	New()
		. = ..()
		START_TRACKING
		booster_image = image('icons/mob/robots.dmi', "up-speed") //default booster_image is the same as used for speed boost upgrade on cyborgs
		if(length(ability_buttons_to_initialize))
			src.setup_ability_buttons()


	disposing()
		if(rider)
			src.visible_message("<span class='alert'><b>The [src] is destroyed!</b></span>")
			eject_rider()
		. = ..()
		STOP_TRACKING

	remove_air(amount)
		return src.loc.remove_air(amount)

	return_air()
		return src.loc.return_air()

	attackby(obj/item/W, mob/user)
		if(src.rider && src.rider_visible && W.force)
			W.attack(src.rider, user)
			user.lastattacked = src // sets click cooldown
			if (attacks_fast_eject || is_incapacitated(rider))
				eject_rider()
			W.visible_message("<span class='alert'>[user] swings at [src.rider] with [W]!</span>")

	bullet_act(obj/projectile/P)
		if(src.rider)
			rider.bullet_act(P)
			eject_rider()
		else
			..()
			if (health_max != null)
				var/damage_unscaled = P.power * P.proj_data.ks_ratio //stam component does nothing- can't tase a grille
				switch(P.proj_data.damage_type)
					if (D_PIERCING)
						src.take_damage(damage_unscaled)
						playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
					if (D_BURNING)
						src.take_damage(damage_unscaled / 2)
					if (D_KINETIC)
						src.take_damage(damage_unscaled / 2)
					if (D_ENERGY)
						src.take_damage(damage_unscaled / 4)
					if (D_SPECIAL) //random guessing
						src.take_damage(damage_unscaled / 4)
						src.take_damage(damage_unscaled / 8)

	proc/take_damage(var/amount)
		if (!isnum(amount))
			CRASH("Non-numeric damage amount \[amount\] passed to /obj/vehicle/take_damage()")
		if (amount <= 0)
			return

		src.health = clamp(src.health - amount, 0, src.health_max)
		if (src.health == 0)
			robogibs(src.loc)
			qdel(src)

	meteorhit()
		if (src.rider && ismob(src.rider))
			src.rider.meteorhit()
			src.eject_rider()

	ex_act(severity)
		switch(severity)
			if(1)
				for(var/atom/movable/A in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)

			if(2)
				if (prob(50))
					for(var/atom/movable/A in src)
						A.set_loc(src.loc)
						A.ex_act(severity)
					qdel(src)

			if(3)
				if (prob(25))
					for(var/atom/movable/A in src)
						A.set_loc(src.loc)
						A.ex_act(severity)
					qdel(src)

	Exited(atom/movable/thing, atom/newloc)
		. = ..()
		if(thing == src.rider)
			src.eject_rider(crashed=FALSE, selfdismount=TRUE, ejectall=FALSE)

	Click(location,control,params)
		if(istype(usr, /mob/dead/observer) && usr.client && !usr.client.keys_modifier && !usr:in_point_mode)
			var/mob/dead/observer/O = usr
			if(src.rider)
				O.insert_observer(src.rider)
		else
			. = ..()

	proc/eject_other_stuff() // override if there's some stuff integral to the vehicle that should not be ejected
		for(var/atom/movable/AM in src)
			AM.set_loc(src.loc)

	/// kick out the rider
	proc/eject_rider(var/crashed, var/selfdismount, var/ejectall = TRUE)
		if(src.rider)
			MOVE_OUT_TO_TURF_SAFE(src.rider, src)
			ClearSpecificOverlays("rider")
			ClearSpecificOverlays("booster_image")
			handle_button_removal()
			src.rider = null
		if (ejectall)
			src.eject_other_stuff()

	was_deconstructed_to_frame(mob/user)
		eject_rider(crashed=FALSE, selfdismount=FALSE, ejectall=TRUE)

	/// remove the ability buttons from the rider
	proc/handle_button_removal()
		if (src.rider?.client)
			for(var/obj/ability_button/B in src.ability_buttons)
				src.rider.client.screen -= B

	/// add the ability buttons to the rider
	proc/handle_button_addition()
		if(!src.rider?.loc == src || !(length(src.ability_buttons)))
			return
		if(ishuman(src.rider))
			var/mob/living/carbon/human/H = rider
			H.hud?.update_ability_hotbar() //automatically adds the vehicle ability buttons
		else if (src.rider) //fix for cannot read null.client
			for(var/obj/ability_button/B in ability_buttons)
				B.the_mob = src.rider
				rider.client?.screen += B //don't have to worry about location since that should already have been handled by initialization

	/// initializes the ability buttons (if we have any)
	proc/setup_ability_buttons()
		if (!islist(src.ability_buttons))
			src.ability_buttons = list()
		var/x_btt = 1 // x-position of button
		for (var/button in src.ability_buttons_to_initialize)
			var/obj/ability_button/NB = new button()
			src.ability_buttons += NB
			NB.screen_loc = "NORTH-2,[x_btt]"
			x_btt++


	// This handles the code that USED to be defined individually in each vehicle's relaymove() proc
	// all non-machinery vehicles except forklifts and skateboards use this now
	relaymove(mob/user as mob, dir)
		// we reset the overlays to null in case the relaymove() call was initiated by a
		// passenger rather than the driver (we shouldn't have a rider overlay if there is no rider!)
		src.overlays = null

		if(!src.rider || user != src.rider)
			return

		var/td = max(src.delay, MINIMUM_EFFECTIVE_DELAY)

		if(src.rider_visible)
			src.overlays += src.rider

		// You can't move in space without the booster upgrade
		if (src.booster_upgrade)
			src.overlays += booster_image
		else
			var/turf/T = get_turf(src)

			if(T.throw_unlimited && istype(T, /turf/space))
				return

		// Next, we do some simple math to adjust the vehicle's glide_size based on its speed and to compensate for lag
		src.glide_size = (32 / td) * world.tick_lag

		// we set the glide_size for all occupants of the vehicle to the same value that we used for the vehicle itself
		// and set the occupant's animate_movement to SYNC_STEPS
		// This helps to SIGNIFICANTLY smooth the apparent motion of the camera at higher speeds (almost buttery at default speed of 2)
		// Unfortunately, there is still some stuttering at higher speeds, but it has been lessened quite a bit.
		for(var/mob/M in src)
			M.glide_size = src.glide_size;
			M.animate_movement = SYNC_STEPS;

		// We finally actually walk the src vehicle in the dir direction with td delay between steps
		// The vehicle will keep moving in this direction until stopped or the direction is changed
		walk(src, dir, td)

		// We.... uhhhhhh... well, we do the glide_size and animation adjustments AGAIN.
		// I really have no idea why we do this, but it was present in pod movement code,
		// and I asked mbc about it and we were both too scared to change it
		// So, if you want to optimize this some more, I'd start by looking into removing that bit of code
		src.glide_size = (32 / td) * world.tick_lag

		for(var/mob/M in src)
			M.glide_size = src.glide_size;
			M.animate_movement = SYNC_STEPS;

		// LASTLY, we call do_special_on_relay() to handle any special behaviors we want the vehicle to perform each time relaymove() is called
		// NOTE: this means that do_special_on_relay() will only get called when the rider is performing a direction input
		//       and NOT whenever the vehicle actually MOVES.
		//       For that, you'll want to override the vehicles Move() proc with the custom behavior you want.
		src.do_special_on_relay(user, dir);

	proc/do_special_on_relay(mob/user as mob, dir) //empty placeholder for when we successfully have the rider relay a move
		return

	proc/Stopped()
		ClearSpecificOverlays("booster_image") //so we don't see thrusters firing on a parked vehicle
		return

	proc/stop()
		walk(src,0)
		Stopped()

	blob_act(var/power)
		qdel(src)

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		..()
		// Simulate hotspot Crossed/Process so turfs engulfed in flames aren't simply ignored in vehicles
		if (src.rider_visible && !src.sealed_cabin && ismob(src.rider) && exposed_volume > (CELL_VOLUME * 0.8) && exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
			src.rider.update_burning(clamp(exposed_temperature / 60, 0, 10))

//////////////////////////////////////////////////////////// Segway ///////////////////////////////////////////

TYPEINFO(/obj/vehicle/segway)
	mats = 8

#define SEGWAY_STATE_RIDDEN 1
#define SEGWAY_STATE_WEEWOO 2
/obj/vehicle/segway
	name = "\improper Space Segway"
	desc = "Now you too can look like a complete tool in space!"
	icon_state = "segway"
	var/icon_base = "segway"
	var/image/image_under = null
	layer = MOB_LAYER + 1
	health = 30
	health_max = 30
	var/weewoo_cycles_remaining = 0 //! Number of light cycles currently left to perform
	var/initial_weewoo_cycles = 10 //! Number of times our lights cycle with each press of the siren button
	soundproofing = FALSE
	can_eject_items = TRUE
	var/datum/light/light
	ability_buttons_to_initialize = list(/obj/ability_button/weeoo)
	var/obj/item/joustingTool = null // When jousting will be reference to lance being used

/obj/vehicle/segway/New()
	..()
	light = new /datum/light/point
	light.set_brightness(0.7)
	light.attach(src)

/obj/vehicle/segway/proc/weeoo()
	if (weewoo_cycles_remaining > 0)
		return

	weewoo_cycles_remaining = 10
	SPAWN(0)
		playsound(src.loc, 'sound/machines/siren_police.ogg', 50, 1)
		light.enable()
		src.icon_state = "[src.icon_base][SEGWAY_STATE_WEEWOO]"
		while (weewoo_cycles_remaining--)
			light.set_color(0.9, 0.1, 0.1)
			sleep(0.3 SECONDS)
			light.set_color(0.1, 0.1, 0.9)
			sleep(0.3 SECONDS)
		light.disable()
		src.update()

/obj/ability_button/weeoo
	name = "Police Siren"
	icon = 'icons/misc/abilities.dmi'
	icon_state = "noise"

	Click()
		if(!the_mob) return

		if (istype(the_mob.loc, /obj/vehicle/segway))
			var/obj/vehicle/segway/seg = the_mob.loc
			seg.weeoo()
		else if (ishuman(the_mob))
			var/mob/living/carbon/human/H = the_mob
			var/obj/item/clothing/head/helmet/siren/S = H.head
			if (istype(S))
				S.weeoo()

/obj/vehicle/segway/proc/update()
	if (rider)
		src.icon_state = "[src.icon_base][SEGWAY_STATE_RIDDEN]"
		if (!src.image_under)
			src.image_under = image(icon = src.icon, icon_state = src.icon_base, layer = MOB_LAYER - 0.1)
		else
			src.image_under.icon = src.icon
			src.image_under.icon_state = src.icon_base
		src.underlays += src.image_under
	else
		src.icon_state = src.icon_base
		src.UpdateOverlays(null, "rider")
		src.underlays = null

/obj/vehicle/segway/bump(atom/AM as mob|obj|turf)
	if(in_bump)
		return
	if(AM == rider || !rider)
		return
	if(ON_COOLDOWN(AM, "vehicle_bump", 10 SECONDS))
		return
	walk(src, 0)
	update()
	..()
	in_bump = TRUE
	if(isturf(AM) && (src.emagged || src.rider.bioHolder.HasEffect("clumsy") || (src.rider.reagents && src.rider.reagents.has_reagent("ethanol"))))
		src.rider.visible_message("<span class='alert'><b>[rider] crashes into the wall with \the [src]!</b></span>", "<span class='alert'><b>[src] crashes into the wall!</b></span>")
		eject_rider(2)
		JOB_XP(rider, "Clown", 1)
		in_bump = FALSE
		return
	if(ismob(AM))
		var/mob/M = AM
		src.rider.tri_message(AM, "<span class='alert'><b>[src.rider] crashes into [AM] with \the [src]!</b></span>",
								  "<span class='alert'><b>[src] crashes into the wall!</b></span>",
								  "<span class='alert'><b>[src.rider] crashes into you with \the [src]!</b></span>")
		// drsingh for undef variable silicon/robot/var/shoes
		// i guess a borg got on a segway? maybe someone was riding one with nanites
		if (ishuman(M))
			if(!istype(M:shoes, /obj/item/clothing/shoes/sandal))
				M.changeStatus("stunned", 5 SECONDS)
				M.changeStatus("weakened", 5 SECONDS)
				M.force_laydown_standup()
				src.log_me(src.rider, M, "impact")
			else
				M.visible_message("<span class='alert'><b>[M] is kept upright by magical sandals!</b></span>", "<span class='alert'><b>Your magical sandals keep you upright!</b></span>")
				src.log_me(src.rider, M, "impact", immune_to_impact=TRUE)
		else
			M.changeStatus("stunned", 5 SECONDS)
			M.changeStatus("weakened", 5 SECONDS)
			src.log_me(src.rider, M, "impact")
		eject_rider(2)
		in_bump = FALSE

	if(isitem(AM))
		if(AM:w_class >= W_CLASS_BULKY)
			src.rider.visible_message("<span class='alert'><b>[src.rider] crashes into [AM] with \the [src]!</b></span>", "<span class='alert'><b>You crash into [AM] with \the [src]!</b></span>")
			eject_rider(1)
			in_bump = FALSE
			return
	if(istype(AM, /obj/vehicle/segway))
		var/obj/vehicle/segway/other_segway = AM
		if(other_segway.rider)
			other_segway.in_bump = TRUE
			src.rider.tri_message(other_segway.rider, "<span class='alert'><b>[src.rider] and [other_segway.rider] crash into each other!</b></span>",
													  "<span class='alert'><b>You crash into [other_segway.rider]'s [other_segway.name]!</b></span>",
													  "<span class='alert'><b>[src.rider] crashes into your [other_segway.name]!</b></span>")

			eject_rider(2)
			other_segway.eject_rider(crashed=TRUE)
			src.log_me(src.rider, other_segway.rider, "impact")
			other_segway.in_bump = FALSE
	in_bump = FALSE

/obj/vehicle/segway/eject_rider(var/crashed, var/selfdismount, var/ejectall = 1)
	if (!src.rider)
		return

	var/mob/living/rider = src.rider
	..()
	rider.pixel_y = 0
	walk(src, 0)
	if(crashed)
		if(crashed == 2)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
		boutput(rider, "<span class='alert'><b>You are flung over \the [src]'s handlebars!</b></span>")
		rider.changeStatus("stunned", 8 SECONDS)
		rider.changeStatus("weakened", 5 SECONDS)
		rider.force_laydown_standup()
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><b>[rider] is flung over \the [src]'s handlebars!</b></span>", 1)
		var/turf/target = get_edge_target_turf(src, src.dir)
		rider.throw_at(target, 5, 1)
		rider = null
		update()
		return
	if(selfdismount)
		boutput(rider, "<span class='notice'>You dismount from \the [src].</span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<b>[rider]</b> dismounts from \the [src].", 1)
	rider = null
	update()
	return

/obj/vehicle/segway/Move()
	. = ..()
	if (joustingTool && ishuman(rider)) // poke at people in three forward squares
		var/mob/living/carbon/human/R = rider
		if (R.equipped() != joustingTool) // you unreadied your lance
			return

		var/list/targets = new /list

		var/turf/nextStep = get_step(src, src.dir)
		targets += getTurfTargets(nextStep) // segway helper proc below

		var/turf/temp = null
		if (src.dir & (WEST | EAST)) // moving w/e, add diagonal potential targets
			temp = get_step(nextStep, NORTH)
			targets += getTurfTargets(temp)
			temp = get_step(nextStep, SOUTH)
			targets += getTurfTargets(temp)
		else if (src.dir & (NORTH | SOUTH)) // facing n/s, add contents of turfs w/e of nextStep
			temp = get_step(nextStep, WEST)
			targets += getTurfTargets(temp)
			temp = get_step(nextStep, EAST)
			targets += getTurfTargets(temp)
		else
			//boutput(world, "What direction are you even facing")
			return
		if (targets.len) // We have contact!
			var/unluckyFucker = pick(targets)
			var/mob/living/carbon/human/T
			var/obj/vehicle/segway/S = null
			if (ishuman(unluckyFucker))
				T = unluckyFucker
			else
				S = unluckyFucker
				T = S.rider


			var/datum/attackResults/msgs = new(R)
			msgs.clear(T)
			msgs.played_sound = joustingTool.hitsound
			msgs.def_zone = pick("chest", "head")
			msgs.logs = list()
			msgs.logc("jousts [constructTarget(T,"combat")] with a [joustingTool]")
			msgs.damage_type = DAMAGE_BLUNT

			//logTheThing(LOG_COMBAT, R, " jousts [constructTarget(src,"diary")] with a [joustingTool]")

			if (S) // they were on a segway, diiiiis-MOUNT!
				S.eject_rider(2)

			if (istype(joustingTool, /obj/item/mop))
				msgs.show_message_self("You slap [T] across the face with your [joustingTool]!")
				msgs.show_message_target("You get slapped across the face by [R]'s jousting mop!")
				msgs.visible_message_target("[T] is slapped in the face with [R]'s jousting mop!")
				msgs.stamina_self = rand(-15, -25)
				msgs.stamina_target = rand(-10,-30)
				msgs.flush()

				if (T.head && prob(20))
					T.show_message("Your hat goes flying!")
					var/obj/item/hat = T.head
					T.u_equip(hat)
					hat.set_loc(T.loc)
					hat.dropped(T)
					hat.throw_at(get_edge_target_turf(T, S.dir), 50, 1)

			else if (istype(joustingTool, /obj/item/experimental/melee/spear)) // don't need custom attackResults here, just use the spear attack, that's deadly enough
				T.Attackby(joustingTool, R)
				R.visible_message("[R] lances [T] with a spear!", "You stab at [T] in passing!")
				if (prob(33))
					R.drop_item(joustingTool)
					joustingTool.set_loc(get_turf(T))
					if (prob(50))
						R.show_message("The spear sticks in [T] and you lose control of [src]!")
						src.eject_rider(2)
					else
						R.show_message("You lose control of your spear!")

			else if (istype(joustingTool, /obj/item/rods))
				msgs.show_message_self("You wallop [T] in passing!")
				msgs.show_message_target("[R] wallops you with a [joustingTool] in passing!")
				msgs.visible_message_target("[R] jousts [T] with a [joustingTool]!")
				msgs.stamina_self = rand(-25, -45)
				msgs.stamina_target = rand(-25,-40)
				msgs.damage = rand(3,10)
				msgs.flush()

				if (prob(20))
					R.show_message("You lose your balance!")
					src.eject_rider(2)
			//else
				//boutput(world, "What the fuck how are you jousting with [joustingTool]")
			joustingTool = null // unready your lance, you've done well valliant knight

/obj/vehicle/segway/proc/getTurfTargets(turf/turf as turf)
	. = new /list
	for (var/mob/living/carbon/human/H in turf.contents)
		. += H
	for (var/obj/vehicle/segway/S in turf.contents)
		if (ishuman(S.rider))
			. += S

/obj/vehicle/segway/MouseDrop_T(mob/living/target, mob/user)
	if (rider || !istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, target) > 0 || is_incapacitated(user) || isAI(user))
		return

	var/msg

	if(target == user && !user.stat)	// if drop self, then climbed in
		msg = "[user.name] climbs onto the [src]."
		boutput(user, "<span class='notice'>You climb onto \the [src].</span>")
	else if(target != user && !user.restrained())
		msg = "[user.name] helps [target.name] onto \the [src]!"
		boutput(user, "<span class='notice'>You help [target.name] onto \the [src]!</span>")
	else
		return
	target.set_loc(src)
	rider = target
	if (rider.client)
		handle_button_addition()
	rider.pixel_x = 0
	rider.pixel_y = 5
	src.UpdateOverlays(rider, "rider")

	for (var/mob/C in AIviewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)

	update()
	return

/obj/vehicle/segway/Click()
	if(usr != rider)
		..()
		return
	if(!(usr.getStatusDuration("paralysis") || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat))
		eject_rider(0, 1)
	return

/obj/vehicle/segway/attack_hand(mob/living/carbon/human/M)
	if(!M || !rider)
		..()
		return
	switch(M.a_intent)
		if("harm", "disarm")
			if(prob(60))
				playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
				src.visible_message("<span class='alert'><b>[M] has shoved [rider] off of the [src]!</b></span>")
				src.log_me(src.rider, M, "shoved_off")
				if (!rider.hasStatus("weakened"))
					rider.changeStatus("weakened", 2 SECONDS)
					rider.force_laydown_standup()
				eject_rider()
			else
				playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 25, 1, -1)
				src.visible_message("<span class='alert'><b>[M] has attempted to shove [rider] off of the [src]!</b></span>")
	return

/obj/vehicle/segway/disposing()
	if(rider)
		boutput(rider, "<span class='alert'><b>Your segway is destroyed!</b></span>")
		eject_rider()
	..()
	return

// Some people get really angry over this, so whatever. Logs would've been helpful on occasion (Convair880).
/obj/vehicle/segway/proc/log_me(var/mob/rider, var/mob/other_dude, var/action = "", var/immune_to_impact = 0)
	if (!src || action == "")
		return

	switch (action)
		if ("impact")
			if (ismob(rider) && ismob(other_dude))
				logTheThing(LOG_VEHICLE, rider, "driving [src] crashes into [constructTarget(other_dude,"vehicle")][immune_to_impact != 0 ? " (immune to impact)" : ""] at [log_loc(src)].")

		if ("shoved_off")
			if (ismob(rider) && ismob(other_dude))
				logTheThing(LOG_VEHICLE, other_dude, "shoves [constructTarget(rider,"vehicle")] off of a [src] at [log_loc(src)].")

	return

/obj/vehicle/segway/emag_act(mob/user, obj/item/card/emag/E)
	if (!src.emagged)
		src.emagged = TRUE
		src.weeoo()
		src.desc = src.desc + " It looks like the safety circuits have been shorted out."
		src.visible_message("<span class='alert'><b>[src] beeps ominously.</b></span>")
		return 1

#undef SEGWAY_STATE_RIDDEN
#undef SEGWAY_STATE_WEEWOO

////////////////////////////////////////////////////// Floor buffer /////////////////////////////////////

TYPEINFO(/obj/vehicle/floorbuffer)
	mats = 8

/obj/vehicle/floorbuffer
	name = "\improper Buff-R-Matic 3000"
	desc = "A snazzy ridable floor buffer with a holding tank for cleaning agents."
	icon_state = "floorbuffer"
	layer = MOB_LAYER + 1
	is_syndicate = 1
	health = 80
	health_max = 80
	var/low_reagents_warning = 0
	var/zamboni = 0
	var/sprayer_active = 0
	var/image/image_under = null
	var/icon_base = "floorbuffer"
	var/rider_state = 1
	delay = 4
	ability_buttons_to_initialize = list(/obj/ability_button/fbuffer_toggle, /obj/ability_button/fbuffer_status)
	soundproofing = 0
	can_eject_items = TRUE

	New()
		..()
		src.create_reagents(1250)
		if(zamboni)
			reagents.add_reagent("cryostylane", 1000)
		else
			reagents.add_reagent("water", 1000)
			//reagents.add_reagent("cleaner", 250) //don't even need this now that we have fluid, probably. If you want it, add it yer self
/*
/obj/ability_button/toggle_buffer
	name = "Toggle Buff-R-Matic Sprayer"
	icon = 'icons/misc/abilities.dmi'
	icon_state = "on"
	var/active = 0

	Click()
		if(!the_mob) return

		var/mob/my_mob = the_mob

		var/obj/vehicle/floorbuffer/FB = null

		if(istype(my_mob.loc, /obj/vehicle/floorbuffer))
			FB = my_mob.loc
			active = !active
			boutput(my_mob, "<span class='notice'><b>You turn [active ? "on" : "off"] the floor buffer's sprayer.</span></b>")
			FB.sprayer_active = active
			src.icon_state = active ? "on" : "off"
			playsound(my_mob.loc, 'sound/machines/click.ogg', 50, 1)

		return
*/
/obj/vehicle/floorbuffer/proc/update()
	if (rider)
		src.icon_state = "floorbuffer[src.sprayer_active]"
		//src.underlays += image(icon = src.icon, icon_state = "floorbuffer1a", layer = MOB_LAYER - 0.1 )
		if (!src.image_under)
			src.image_under = image(icon = src.icon, icon_state = src.icon_base, layer = MOB_LAYER - 0.1)
		else
			src.image_under.icon_state = src.icon_base
		src.underlays += src.image_under
	else
		src.icon_state = src.icon_base
		src.UpdateOverlays(null, "rider")
		src.underlays = null

/obj/vehicle/floorbuffer/Move()
	. = ..()
	if(. && rider)
		pixel_x = rand(-1, 1)
		pixel_y = rand(-1, 1)
		SPAWN(1 DECI SECOND)
			pixel_x = rand(-1, 1)
			pixel_y = rand(-1, 1)
		if (!src.sprayer_active)
			var/turf/T = get_turf(src)
			if (istype(T) && T.active_liquid)
				if (T.active_liquid.group && length(T.active_liquid.group.members) > 20) //Drain() is faster. use this if the group is large.
					if (prob(20))
						playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)

					if (T.active_liquid.group)
						T.active_liquid.group.queued_drains += rand(2,4)
						T.active_liquid.group.last_drain = T
						if (!T.active_liquid.group.draining)
							T.active_liquid.group.add_drain_process()
					//T.active_liquid.group.drain(T.active_liquid, rand(2,4))

				else
					T.active_liquid.removed(1)
			return
		SPAWN(0)
			if (src.reagents.total_volume < 1)
				return

			if(src.reagents.has_reagent("water") || src.reagents.has_reagent("cleaner"))
				JOB_XP(rider, "Janitor", 1)

			else if(src.reagents.total_volume < 250 && !low_reagents_warning)
				low_reagents_warning = 1
				boutput(rider, "<span class='notice'><b>The \"Storage Tank Low\" indicator light starts blinking on [src]'s dashboard.</b></span>")
				for (var/obj/ability_button/fbuffer_status/SB in src)
					SB.icon_state = "bufferf-low"
				playsound(src, 'sound/machines/twobeep.ogg', 50)
			else if(src.reagents.total_volume >= 250)
				low_reagents_warning = 0
				for (var/obj/ability_button/fbuffer_status/SB in src)
					SB.icon_state = "bufferf"

			var/obj/decal/D = new/obj/decal(get_turf(src))
			D.name = null
			D.icon = null
			D.invisibility = INVIS_ALWAYS
			D.create_reagents(5)
			src.reagents.trans_to(D, 5)

			var/turf/D_turf = get_turf(D)
			D.reagents.reaction(D_turf)
			for(var/atom/T in D_turf)
				D.reagents.reaction(T)
			sleep(0.3 SECONDS)
			if (D_turf.active_liquid)
				D_turf.active_liquid.try_connect_to_adjacent()

			qdel(D)

/obj/vehicle/floorbuffer/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/reagent_containers) && W.is_open_container() && W.reagents)
		if(!W.reagents.total_volume)
			boutput(user, "<span class='alert'>[W] is empty.</span>")
			return

		if(src.reagents.total_volume >= src.reagents.maximum_volume)
			boutput(user, "<span class='alert'>The [src.name]'s holding tank is full!</span>")
			return

		logTheThing(LOG_CHEMISTRY, user, "pours chemicals [log_reagents(W)] into the [src] at [log_loc(src)].") // Logging for floor buffers (Convair880).
		var/trans = W.reagents.trans_to(src, W.reagents.total_volume)
		boutput(user, "<span class='notice'>You empty [trans] units of the solution into the [src.name]'s holding tank.</span>")
		return
	..()

/obj/vehicle/floorbuffer/is_open_container()
	return 2

/obj/vehicle/floorbuffer/bump(atom/AM as mob|obj|turf)
	if(in_bump)
		return
	if(AM == rider || !rider)
		return
	if(ON_COOLDOWN(AM, "vehicle_bump", 10 SECONDS))
		return
	walk(src, 0)
	update()
	..()
	in_bump = 1
	if(ismob(AM) && src.booster_upgrade)
		var/mob/M = AM
		boutput(rider, "<span class='alert'><b>You crash into [M]!</b></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><b>[rider] crashes into [M] with \the [src]!</b></span>", 1)
		M.changeStatus("stunned", 5 SECONDS)
		M.changeStatus("weakened", 3 SECONDS)
		in_bump = 0
		return
	if(isitem(AM))
		..()
		in_bump = 0
		return
	if(istype(AM, /obj/vehicle/segway))
		var/obj/vehicle/segway/SG = AM
		if(SG.rider)
			SG.in_bump = 1
			var/mob/M = SG.rider
			var/mob/N = rider
			boutput(N, "<span class='alert'><b>You crash into [M]'s [SG.name]!</b></span>")
			boutput(M, "<span class='alert'><b>[N] crashes into your [SG.name]!</b></span>")
			for (var/mob/C in AIviewers(src))
				if(C == N || C == M)
					continue
				C.show_message("<span class='alert'><b>[N] and [M] crash into each other!</b></span>", 1)
			SG.eject_rider(1)
			in_bump = 0
			SG.in_bump = 0
			return
	in_bump = 0
	return

/obj/vehicle/floorbuffer/eject_rider(var/crashed, var/selfdismount, var/ejectall = 1)
	var/mob/living/rider = src.rider
	..()
	rider.pixel_y = 0
	walk(src, 0)
	src.log_rider(rider, 1)
	if(crashed)
		if(crashed == 2)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
		boutput(rider, "<span class='alert'><b>You are flung over \the [src]'s handlebars!</b></span>")
		rider.changeStatus("stunned", 8 SECONDS)
		rider.changeStatus("weakened", 5 SECONDS)
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><b>[rider] is flung over \the [src]'s handlebars!</b></span>", 1)
		var/turf/target = get_edge_target_turf(src, src.dir)
		rider.throw_at(target, 5, 1)
		rider = null
		update()
		return
	if(selfdismount)
		boutput(rider, "<span class='notice'>You dismount from \the [src].</span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<b>[rider]</b> dismounts from \the [src].", 1)
	rider = null
	update()
	return

/obj/vehicle/floorbuffer/MouseDrop_T(mob/living/target, mob/user)
	if (rider || !istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, target) > 0 || is_incapacitated(user) || isAI(user))
		return

	var/msg

	if(target == user && !user.stat)	// if drop self, then climbed in
		msg = "[user.name] climbs onto the [src]."
		boutput(user, "<span class='notice'>You climb onto \the [src].</span>")
		src.log_rider(user, 0)
	else if(target != user && !user.restrained())
		msg = "[user.name] helps [target.name] onto \the [src]!"
		boutput(user, "<span class='notice'>You help [target.name] onto \the [src]!</span>")
		src.log_rider(target, 0)
	else
		return

	target.set_loc(src)
	rider = target
	if (target.client)
		handle_button_addition()
	rider.pixel_x = 0
	rider.pixel_y = 10
	src.UpdateOverlays(rider, "rider")

	for (var/mob/C in AIviewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)

	update()
	return

/obj/vehicle/floorbuffer/Click()
	if(usr != rider)
		..()
		return
	if(!is_incapacitated(usr))
		eject_rider(0, 1)
	return

/obj/vehicle/floorbuffer/attack_hand(mob/living/carbon/human/M)
	if(!M || !rider)
		..()
		return
	switch(M.a_intent)
		if("harm", "disarm")
			if(prob(70) || M.is_hulk())
				playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
				src.visible_message("<span class='alert'><b>[M] has yanked [rider] off of \the [src]!</b></span>")
				if (!rider.hasStatus("weakened"))
					rider.changeStatus("weakened", 2 SECONDS)
					rider.force_laydown_standup()
				eject_rider()
			else
				playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 25, 1, -1)
				src.visible_message("<span class='alert'><b>[M] has attempted to yank [rider] off of \the [src]!</b></span>")
	return

/obj/vehicle/floorbuffer/disposing()
	if(rider)
		boutput(rider, "<span class='alert'><b>Your [src.name] is destroyed!</b></span>")
		eject_rider()
	..()
	return

// Ditto, more logs (Convair880).
/obj/vehicle/floorbuffer/proc/log_rider(var/mob/rider, var/mount_or_dismount = 0)
	if (!src || !rider || !ismob(rider))
		return

	logTheThing(LOG_VEHICLE, rider, "[mount_or_dismount == 0 ? "mounts" : "dismounts"] \a [src.name] [log_reagents(src)] at [log_loc(src)].")
	return

/obj/ability_button/fbuffer_toggle
	name = "Floor Buffer Toggle"
	icon = 'icons/misc/abilities.dmi'
	icon_state = "buffer0"
	screen_loc = "NORTH-2,1"

	Click()
		if (!the_mob)
			return
		if (istype(the_mob.loc, /obj/vehicle/floorbuffer))
			var/obj/vehicle/floorbuffer/FB = the_mob.loc
			FB.sprayer_active = !FB.sprayer_active
			if (FB.sprayer_active)
				boutput(the_mob, "<span class='notice'><b>You turn on [FB]'s sprayer.</span></b>")
			else
				boutput(the_mob, "<span class='notice'><b>You turn off [FB]'s sprayer - the buffer will now dry puddles.</span></b>")
			src.icon_state = "buffer[FB.sprayer_active]"
			if (FB.rider)
				FB.icon_state = "[FB.icon_base][FB.sprayer_active]"
			playsound(the_mob, 'sound/machines/click.ogg', 50, 1)
		return

/obj/ability_button/fbuffer_status
	name = "Floor Buffer Tank Status"
	icon = 'icons/misc/abilities.dmi'
	icon_state = "bufferf"
	screen_loc = "NORTH-3,1"

	Click()
		if (!the_mob)
			return
		if (istype(the_mob.loc, /obj/vehicle/floorbuffer))
			var/obj/vehicle/floorbuffer/FB = the_mob.loc
			if (FB.reagents)
				boutput(the_mob, "<span class='notice'><b>[FB]'s tank is [get_fullness(FB.reagents.total_volume / FB.reagents.maximum_volume * 100)].</b></span>")
		return

/////////////////////////////////////////////////////// Clown car ////////////////////////////////////////

TYPEINFO(/obj/vehicle/clowncar)
	mats = 15

/obj/vehicle/clowncar
	name = "Clown Car"
	desc = "A funny-looking car designed for circus events. Seats 30, very roomy!"
	icon_state = "clowncar"
	var/antispam = 0
	var/moving = 0
	rider_visible = 0
	is_syndicate = 1
	ability_buttons_to_initialize = list(/obj/ability_button/loudhorn/clowncar, /obj/ability_button/drop_peel, /obj/ability_button/stopthebus/clowncar)
	soundproofing = 5
	var/second_icon = "clowncar2" //animated jiggling for the clowncar
	var/peel_count = 5

/obj/vehicle/clowncar/do_special_on_relay(mob/user as mob, dir)
	for (var/mob/living/L in src)
		if (ishuman(L))
			var/mob/living/carbon/human/H = L
			if (H.sims)
				H.sims.affectMotive("fun", 1)
				H.sims.affectMotive("Hunger", 1)
				H.sims.affectMotive("Thirst", 1)
	icon_state = second_icon
	moving = 1
	if(!(world.timeofday - src.antispam <= 60))
		src.antispam = world.timeofday
		playsound(src, 'sound/machines/rev_engine.ogg', 50, 1)
		playsound(src.loc, 'sound/machines/rev_engine.ogg', 50, 1)
		//play engine sound
	return

/obj/vehicle/clowncar/proc/stuff_inside(mob/user, mob/victim)
	victim.set_loc(src)
	src.log_me(user, victim, "pax_enter", 1)
	src.visible_message("[user.name] stuffs [victim.name] into the back of the [src]!")
	boutput(user, "<span class='notice'>You stuff [victim.name] into the back of the [src]!</span>")

/obj/vehicle/clowncar/proc/eject_all(mob/user)
	if(!length(src.contents))
		return
	if (user)
		playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
		src.visible_message("<span class='alert'><b>[user] opens up the [src], spilling the contents out!</b></span>")
	else
		src.visible_message("<span class='alert'><b>Everything in the [src] flies out!</b></span>")

	for(var/atom/A in src.contents)
		if(ismob(A))
			var/mob/N = A
			if (N != src.rider)
				src.log_me(src.rider, N, "pax_exit")
				if (user)
					N.show_message("<span class='alert'><b>You are let out of the [src] by [user]!</b></span>", 1)
				else
					N.show_message("<span class='alert'><b>You are flung out of the [src]!</b></span>", 1)
				N.set_loc(src.loc)
			else
				N.changeStatus("weakened", 2 SECONDS)
				src.eject_rider()
		else if (isobj(A))
			var/obj/O = A
			O.set_loc(src.loc)

/obj/vehicle/clowncar/Click()
	if(usr != rider)
		..()
		return
	if(!(usr.getStatusDuration("paralysis") || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat))
		eject_rider(0, 1, 0)
	return

/obj/vehicle/clowncar/attack_hand(mob/living/M)
	if(!M)
		..()
		return
	if (ismobcritter(M))
		var/mob/living/critter/C = M
		if (isghostcritter(C))
			..()
			return

	playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
	if(rider && prob(40))
		playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
		src.visible_message("<span class='alert'><b>[M] has pulled [rider] out of the [src]!</b></span>")
		if (!rider.hasStatus("weakened"))
			rider.changeStatus("weakened", 2 SECONDS)
			rider.force_laydown_standup()
		eject_rider(0, 0, 0)
	else
		if(src.contents.len)
			src.eject_all()
		else
			boutput(M, "<span class='notice'>There's nothing inside of the [src].</span>")

/obj/vehicle/clowncar/MouseDrop_T(atom/target, mob/user)
	if (!target || LinkBlocked(target.loc,src.loc) || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, target) > 0 || is_incapacitated(user) || isAI(user) || isghostcritter(user))
		return

	if (istype(target, /obj/item/bananapeel))
		src.add_peel(target, user)
		return

	var/mob/living/mob_target = target
	if (!istype(mob_target) || mob_target.buckled)
		return

	var/msg

	var/clown_tally = 0
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		clown_tally = human.clown_tally()
	if(clown_tally < 2 && !IS_LIVING_OBJECT_USING_SELF(user))
		boutput(user, "<span class='notice'>You don't feel funny enough to use the [src].</span>")
		return

	if(mob_target == user && !user.stat)	// if drop self, then climbed in
		if(rider)
			return
		mob_target.set_loc(src)
		rider = mob_target
		handle_button_addition()
		src.log_me(src.rider, null, "rider_enter")
		msg = "[user.name] climbs into the driver's seat of the [src]."
		boutput(user, "<span class='notice'>You climb into the driver's seat of the [src].</span>")
	else if(mob_target != user && !user.restrained() && is_incapacitated(mob_target))
		src.stuff_inside(user, mob_target)
	else
		return
	for (var/mob/C in AIviewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)
	return

/obj/vehicle/clowncar/bump(atom/AM as mob|obj|turf)
	if(in_bump)
		return
	if(AM == rider || !rider)
		return
	if(ON_COOLDOWN(AM, "vehicle_bump", 10 SECONDS))
		return
	walk(src, 0)
	moving = 0
	icon_state = "clowncar"
	..()
	in_bump = 1
	if(isturf(AM))
		boutput(rider, "<span class='alert'><b>You crash into the wall!</b></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><b>[rider] crashes into the wall with the [src]!</b></span>", 1)
		eject_rider(2)
		in_bump = 0
		return
	if(ismob(AM))
		DEBUG_MESSAGE("Bumped [AM] and gonna bowl 'em over.")
		bumpstun(AM)

//		eject_rider(2)
		in_bump = 0
		return
	if(istype(AM, /obj/vehicle/segway))
		var/obj/vehicle/segway/SG = AM
		if(SG.rider)
			SG.in_bump = 1
			var/mob/M = SG.rider
			var/mob/N = rider
			boutput(N, "<span class='alert'><b>You crash into [M]'s [SG]!</b></span>")
			boutput(M, "<span class='alert'><b>[N] crashes into your [SG]!</b></span>")
			for (var/mob/C in AIviewers(src))
				if(C == N || C == M)
					continue
				C.show_message("<span class='alert'><b>[N] crashes into [M]'s [SG]!</b></span>", 1)
			SG.eject_rider(1)
			in_bump = 0
			SG.in_bump = 0
			return
	in_bump = 0
	return

/obj/vehicle/clowncar/Bumped(var/atom/movable/AM as mob|obj)
	if (moving && ismob(AM) && !isghostcritter(AM)) //If we're moving and they're in front of us then bump they
		walk(src, 0)
		moving = 0
		bumpstun(AM)

	..()

/obj/vehicle/clowncar/proc/bumpstun(var/mob/M)
	if(istype(M))
		boutput(rider, "<span class='alert'><b>You crash into [M]!</b></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><b>[rider] crashes into [M] with the [src]!</b></span>", 1)
		M.changeStatus("stunned", 8 SECONDS)
		M.changeStatus("weakened", 5 SECONDS)
		M.force_laydown_standup()
		playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)

/obj/vehicle/clowncar/bullet_act(flag, A as obj)
	if (src.rider && ismob(src.rider) && prob(30))
		src.rider.bullet_act(flag, A)
		src.eject_rider(1)
	return

/obj/vehicle/clowncar/meteorhit()
	if(prob(60))
		eject_rider(2)
	return

/obj/vehicle/clowncar/disposing()
	if(rider)
		boutput(rider, "<span class='alert'><b>Your [src] is destroyed!</b></span>")
		eject_rider(1)
	..()
	return

/obj/vehicle/clowncar/eject_rider(var/crashed, var/selfdismount, var/ejectall = 1)
	if (!src.rider || !ismob(src.rider))
		return
	var/mob/living/rider = src.rider
	..()
	walk(src, 0)
	moving = 0
	src.log_me(src.rider, null, "rider_exit")
	if(crashed)
		if(crashed == 2)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
		playsound(src.loc, "shatter", 40, 1)
		boutput(rider, "<span class='alert'><b>You are flung through the [src]'s windshield!</b></span>")
		rider.changeStatus("stunned", 8 SECONDS)
		rider.changeStatus("weakened", 5 SECONDS)
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><b>[rider] is flung through the [src]'s windshield!</b></span>", 1)
		var/turf/target = get_edge_target_turf(src, src.dir)
		rider.throw_at(target, 5, 1)
		rider = null
		icon_state = "clowncar"
		if(prob(40))
			src.eject_all()
		return
	if(selfdismount)
		boutput(rider, "<span class='notice'>You climb out of the [src].</span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<b>[rider]</b> climbs out of the [src].", 1)
	rider = null
	icon_state = "clowncar"
	return

/obj/vehicle/clowncar/attackby(var/obj/item/I, var/mob/user)
	var/clown_tally = 0
	if(ishuman(user))
		if(istype(user:w_uniform, /obj/item/clothing/under/misc/clown))
			clown_tally += 1
		if(istype(user:shoes, /obj/item/clothing/shoes/clown_shoes))
			clown_tally += 1
		if(istype(user:wear_mask, /obj/item/clothing/mask/clown_hat))
			clown_tally += 1
	if(clown_tally < 2)
		boutput(user, "<span class='notice'>You don't feel funny enough to use the [src].</span>")
		return

	if (istype(I, /obj/item/bananapeel))
		user.drop_item(I)
		src.add_peel(I)
		return

	var/obj/item/grab/G = I
	if(istype(G))	// handle grabbed mob
		if(ismob(G.affecting))
			src.stuff_inside(user, G.affecting)
			for (var/mob/C in AIviewers(src))
				if(C == user)
					continue
				C.show_message("<span class='alert'><b>[G.affecting.name] has been stuffed into the back of the [src] by [user]!</b></span>", 3)
			qdel(G)
			return
	..()
	return

/obj/vehicle/clowncar/proc/add_peel(obj/item/bananapeel/peel, mob/user)
	src.peel_count++
	qdel(peel)
	boutput(user, "<span class='notice'>You stuff the banana peel into the [src]'s peel hopper. It now contains [src.peel_count] peel[src.peel_count > 1 ? "s" : ""].")

// Could be useful, I guess (Convair880).
/obj/vehicle/clowncar/proc/log_me(var/mob/rider, var/mob/pax, var/action = "", var/forced_in = 0)
	if (!src || action == "")
		return

	switch (action)
		if ("rider_enter", "rider_exit")
			if (rider && ismob(rider))
				logTheThing(LOG_VEHICLE, rider, "[action == "rider_enter" ? "starts driving" : "stops driving"] [src.name] at [log_loc(src)].")

		if ("pax_enter", "pax_exit")
			if (pax && ismob(pax))
				var/logtarget = (rider && ismob(rider) ? rider : null)
				logTheThing(LOG_VEHICLE, pax, "[action == "pax_enter" ? "is stuffed into" : "is ejected from"] [src.name] ([forced_in == 1 ? "Forced by" : "Driven by"]: [rider && ismob(rider) ? "[constructTarget(logtarget,"vehicle")]" : "N/A or unknown"]) at [log_loc(src)].")

	return

/obj/vehicle/clowncar/train
	name = "clown train"
	desc = "This car seems... Old fashioned?"

/obj/vehicle/clowncar/train/stuff_inside(mob/user, mob/victim)
	var/atom/movable/current = src
	while (current.GetComponent(/datum/component/train))
		var/datum/component/train/train = current.GetComponent(/datum/component/train)
		current = train.cart
		if (current == victim) //don't attach them if they're already in the chain
			return
	current.AddComponent(/datum/component/train, victim)
	victim.set_loc(get_turf(current))
	src.visible_message("[user.name] attaches [victim.name] to the back of the [src]!")
	boutput(user, "<span class='notice'>You attach [victim.name] to the back of the [src]!</span>")

/obj/vehicle/clowncar/train/eject_all(mob/user)
	var/atom/movable/current = src
	while (current.GetComponent(/datum/component/train))
		var/datum/component/train/train = current.GetComponent(/datum/component/train)
		var/next = train.cart
		train.RemoveComponent()
		current = next

/obj/vehicle/clowncar/cluwne
	name = "cluwne car"
	desc = "A hideous-looking piece of shit on wheels. You probably shouldn't drive this."
	icon_state = "cluwnecar"
	second_icon = "cluwnecar2"

/obj/vehicle/clowncar/cluwne/Move()
	if(..())
		if(prob(2) && rider)
			eject_rider(1)
		pixel_x = rand(-6, 6)
		pixel_y = rand(-2, 2)
		SPAWN(1 DECI SECOND)
			pixel_x = rand(-6, 6)
			pixel_y = rand(-2, 2)
		return TRUE

/obj/vehicle/clowncar/cluwne/attackby(var/obj/item/W, var/mob/user)
	eject_rider()
	W.attack(rider, user)
	user.lastattacked = src

/obj/vehicle/clowncar/cluwne/eject_rider(var/crashed, var/selfdismount, var/ejectall = 1)
	..(crashed, selfdismount)
	icon_state = "cluwnecar"
	pixel_x = 0
	pixel_y = 0

/obj/vehicle/clowncar/cluwne/bump(atom/AM as mob|obj|turf)
	..(AM)
	icon_state = "cluwnecar"
	pixel_x = 0
	pixel_y = 0

/obj/vehicle/clowncar/cluwne/MouseDrop_T(mob/living/target, mob/user)
	if (!istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, target) > 0 || is_incapacitated(user) || isAI(user))
		return

	var/msg

	if(!user.mind || !iscluwne(user))
		boutput(user, "<span class='alert'>You think it's a REALLY bad idea to use the [src].</span>")
		return

	if(target == user && !user.stat)	// if drop self, then climbed in
		if(rider)
			return
		rider = target
		actions.interrupt(target, INTERRUPT_ACT)
		src.log_me(src.rider, null, "rider_enter")
		msg = "[user.name] climbs into the driver's seat of the [src]."
		boutput(user, "<span class='notice'>You climb into the driver's seat of the [src].</span>")
	else
		return

	target.set_loc(src)
	for (var/mob/C in AIviewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)
	return

/obj/vehicle/clowncar/surplus
	name = "Clown Car"
	desc = "A funny-looking car designed for circus events. Seats 30, very roomy! Comes with a free set of clown clothes!"
	icon_state = "clowncar"

	New()
		..()
		new /obj/item/storage/box/costume/clown(src.loc)

//////////////////////////////////////////////////// Rideable cats /////////////////////////////////////////////////////

/obj/vehicle/cat
	name = "Rideable Cat"
	desc = "He looks happy... how odd!"
	icon_state = "segwaycat"
	layer = MOB_LAYER + 1
	soundproofing = 0
	can_eject_items = TRUE

// Might as well make use of the Garfield sprites (Convair880).

/obj/vehicle/cat/garfield
	name = "Garfield??"
	desc = "I'm not overweight, I'm undertall."
	icon_state = "garfield"

/obj/vehicle/cat/odie
	name = "Odie??"
	desc = "Arf arf arf!"
	icon_state = "odie"

/obj/vehicle/cat/bump(atom/AM as mob|obj|turf)
	if(in_bump)
		return
	if(AM == rider || !rider)
		return
	if(ON_COOLDOWN(AM, "vehicle_bump", 10 SECONDS))
		return
	walk(src, 0)
	..()
	in_bump = 1
	if(isturf(AM) && (rider.bioHolder.HasEffect("clumsy") || rider.reagents.has_reagent("ethanol")))
		boutput(rider, "<span class='alert'><b>You run to the wall!</b></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><b>[rider] runs into the wall with the [src]!</b></span>", 1)
		eject_rider(2)
		in_bump = 0
		return
	if(ismob(AM))
		var/mob/M = AM
		boutput(rider, "<span class='alert'><b>You run into [M]!</b></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><b>[rider] runs into [M] with the [src]!</b></span>", 1)
		M.changeStatus("stunned", 8 SECONDS)
		M.changeStatus("weakened", 5 SECONDS)
		eject_rider(2)
		in_bump = 0
		return
	if(isitem(AM))
		if(AM:w_class >= W_CLASS_BULKY)
			boutput(rider, "<span class='alert'><b>You run into [AM]!</b></span>")
			for (var/mob/C in AIviewers(src))
				if(C == rider)
					continue
				C.show_message("<span class='alert'><b>[rider] runs into [AM] with the [src]!</b></span>", 1)
			eject_rider(1)
			in_bump = 0
			return
	if(istype(AM, /obj/vehicle/segway))
		var/obj/vehicle/segway/SG = AM
		if(SG.rider)
			SG.in_bump = 1
			var/mob/M = SG.rider
			var/mob/N = rider
			boutput(N, "<span class='alert'><b>You run into [M]'s [SG]!</b></span>")
			boutput(M, "<span class='alert'><b>[N] runs into your [SG]!</b></span>")
			for (var/mob/C in AIviewers(src))
				if(C == N || C == M)
					continue
				C.show_message("<span class='alert'><b>[N] and [M] crash into each other!</b></span>", 1)
			eject_rider(2)
			SG.eject_rider(1)
			in_bump = 0
			SG.in_bump = 0
			return
	in_bump = 0
	return

/obj/vehicle/cat/eject_rider(var/crashed, var/selfdismount, var/ejectall = 1)
	var/mob/living/rider = src.rider
	..()
	rider.pixel_y = 0
	src.icon_state = initial(src.icon_state)
	walk(src, 0)
	if(crashed)
		if(crashed == 2)
			playsound(src.loc, 'sound/voice/animal/cat.ogg', 70, 1)
		boutput(rider, "<span class='alert'><b>You are flung over the [src]'s head!</b></span>")
		rider.changeStatus("stunned", 8 SECONDS)
		rider.changeStatus("weakened", 5 SECONDS)
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><b>[rider] is flung over the [src]'s head!</b></span>", 1)
		var/turf/target = get_edge_target_turf(src, src.dir)
		rider.throw_at(target, 5, 1)
		rider = null
		ClearSpecificOverlays("rider")
		return
	if(selfdismount)
		boutput(rider, "<span class='notice'>You dismount from the [src].</span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<b>[rider]</b> dismounts from the [src].", 1)
	rider = null
	ClearSpecificOverlays("rider")
	return

/obj/vehicle/cat/do_special_on_relay(mob/user as mob, dir)
	switch(dir)
		if(NORTH,SOUTH)
			layer = MOB_LAYER+1// TODO Layer wtf
		if(EAST,WEST)
			layer = 3
	return

/obj/vehicle/cat/MouseDrop_T(mob/living/target, mob/user)
	if (rider || !istype(target) || target.buckled || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, target) > 0 || user.hasStatus(list("weakened", "paralysis", "stunned")) || user.stat || isAI(user))
		return

	var/msg

	if(target == user && !user.stat)	// if drop self, then climbed in
		msg = "[user.name] climbs onto the [src]."
		boutput(user, "<span class='notice'>You climb onto the [src].</span>")
	else if(target != user && !user.restrained())
		msg = "[user.name] helps [target.name] onto the [src]!"
		boutput(user, "<span class='notice'>You help [target.name] onto the [src]!</span>")
	else
		return

	target.set_loc(src)
	rider = target
	rider.pixel_x = 0
	rider.pixel_y = 5
	src.UpdateOverlays(rider, "rider")
	src.icon_state = "[src.icon_state]1"

	for (var/mob/C in AIviewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)

	return

/obj/vehicle/cat/Click()
	if(usr != rider)
		..()
		return
	if(!(usr.getStatusDuration("paralysis") || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat))
		eject_rider(0, 1)
	return

/obj/vehicle/cat/attack_hand(mob/living/carbon/human/M)
	if(!M || !rider)
		..()
		return
	switch(M.a_intent)
		if("harm", "disarm")
			if(prob(60))
				playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
				src.visible_message("<span class='alert'><b>[M] has shoved [rider] off of the [src]!</b></span>")
				if (!rider.hasStatus("weakened"))
					rider.changeStatus("weakened", 2 SECONDS)
					rider.force_laydown_standup()
				eject_rider()
			else
				playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 25, 1, -1)
				src.visible_message("<span class='alert'><b>[M] has attempted to shove [rider] off of the [src]!</b></span>")
	return


/obj/vehicle/cat/disposing()
	if(rider)
		boutput(rider, "<span class='alert'><b>Your cat is destroyed!</b></span>")
		eject_rider()
	..()
	return

////////////////////////////////////////////////// Admin bus /////////////////////////////////////

TYPEINFO(/obj/vehicle/adminbus)
	mats = 15

/obj/vehicle/adminbus
	name = "Admin Bus"
	desc = "A short yellow bus that looks reinforced."
	var/badmin_name = "Badmin Bus"
	var/badmin_desc = "A short bus painted in blood that looks horrifyingly evil."
	icon_state = "adminbus"
	var/nonmoving_state = "adminbus"
	var/moving_state = "adminbus2"
	var/badmin_moving_state = "badminbus2"
	var/badmin_nonmoving_state = "badminbus"
	var/antispam = 0
	is_syndicate = 1
	sealed_cabin = 1
	rider_visible = 0
	ability_buttons_to_initialize = list(/obj/ability_button/loudhorn, /obj/ability_button/stopthebus, /obj/ability_button/togglespook)
	var/gib_onhit = 0
	var/is_badmin_bus = FALSE
	var/darkness = FALSE
	booster_upgrade =1
	delay = 1
	soundproofing = 5

	New()
		..()
		booster_image = image('icons/obj/vehicles.dmi', "boost-bus")

/obj/vehicle/adminbus/Move()
	if(src.darkness)
		if(prob(3))
			src.do_darkness()

	return ..()

/obj/ability_button/loudhorn
	name = "Loudhorn"
	icon = 'icons/misc/abilities.dmi'
	icon_state = "noise"
	var/mysound = 'sound/musical_instruments/Vuvuzela_1.ogg'
	var/mydelay = 1 SECOND
	var/myvolume = 50
	var/active = 0

	Click(location, control, params)
		. = ..()
		if(!the_mob) return
		if(active) return

		var/the_turf = get_turf(the_mob)
		active = 1
		var/mob/my_mob = the_mob

		if(!isturf(my_mob.loc))
			playsound(my_mob.loc, src.mysound, src.myvolume, 1)
		playsound(the_turf, src.mysound, src.myvolume, 1)

		SPAWN(src.mydelay)
			active = 0

/obj/ability_button/loudhorn/clowncar
	name = "Clown Car Horn"
	icon = 'icons/misc/abilities.dmi'
	icon_state = "noise"
	mysound = 'sound/musical_instruments/Carhorn_1.ogg'
	mydelay = 10 SECONDS
	myvolume = 75

/obj/ability_button/stopthebus
	name = "Stop The Bus"
	icon = 'icons/misc/ManuUI.dmi'
	icon_state = "cancel"
	var/active = 0
	var/mydelay = 0 SECONDS

	Click(location, control, params)
		. = ..()
		if(!the_mob) return
		if(active)
			boutput( the_mob, "<span class='alert'>The brake is on cooldown!</span>" )
			return
		var/mob/my_mob = the_mob
		if(!istype(my_mob.loc, /obj/vehicle)) return
		active = 1
		var/obj/vehicle/v = my_mob.loc
		v.stop()

		SPAWN(src.mydelay)
			active = 0

	clowncar
		name = "Stop The Car"
		mydelay = 2 SECONDS

/obj/ability_button/drop_peel
	name = "Drop a banana peel"
	icon = 'icons/misc/abilities.dmi'
	icon_state = "peel"

	Click(location, control, params)
		. = ..()
		if (!istype(src.the_mob?.loc, /obj/vehicle/clowncar))
			return
		var/obj/vehicle/clowncar/car = src.the_mob.loc
		if (car.peel_count <= 0)
			boutput(src.the_mob, "<span class='alert'>No peels left!</span>")
			return
		playsound(car, 'sound/machines/click.ogg', 50, 1)
		new /obj/item/bananapeel(get_turf(car))
		car.peel_count--

/obj/ability_button/togglespook
	name = "Toggle Spook"
	icon = 'icons/ui/context32x32.dmi'
	icon_state = "wraith-break-lights"

	Click(location, control, params)
		. = ..()
		if (!the_mob)
			return
		if(istype(the_mob.loc, /obj/vehicle/adminbus/))
			var/obj/vehicle/adminbus/bus = usr.loc
			bus.darkness = !bus.darkness
			if (bus.darkness)
				boutput( the_mob, "<span class='alert'>The air grows heavy and nearby lights begin to flicker and dim!</span>" )
			else
				boutput( the_mob, "<span class='alert'>Things seem to return to normal.</span>" )

/obj/vehicle/adminbus/Stopped()
	..()
	icon_state = nonmoving_state

/obj/vehicle/adminbus/do_special_on_relay(mob/user as mob, dir)
	icon_state = moving_state
	if(!(world.timeofday - src.antispam <= 60))
		src.antispam = world.timeofday
		playsound(src, 'sound/machines/rev_engine.ogg', 50, 1)
		playsound(src.loc, 'sound/machines/rev_engine.ogg', 50, 1)
		//play engine sound
		return

// the adminbus has a pressurized cabin!
/obj/vehicle/adminbus/handle_internal_lifeform(mob/lifeform_inside_me, breath_request, mult)
	var/datum/gas_mixture/GM = new /datum/gas_mixture

	var/oxygen = MOLES_O2STANDARD
	var/nitrogen = MOLES_N2STANDARD
	var/sum = oxygen + nitrogen

	GM.oxygen = (oxygen/sum)*breath_request * mult
	GM.nitrogen = (nitrogen/sum)*breath_request * mult
	GM.temperature = T20C

	return GM

/obj/vehicle/adminbus/Click()
	if(usr != rider)
		var/mob/M = usr
		if(M.client && M.client.holder && M.loc == src)
			M.show_message(text("<span class='alert'><b>You exit the []!</b></span>", src), 1)
			M.remove_adminbus_powers()
			M.set_loc(src.loc)
			return
		..()
		return
	if(!(usr.getStatusDuration("paralysis") || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat))
		eject_rider(0, 1, 0)
	return

/obj/vehicle/adminbus/attack_hand(mob/living/carbon/human/M)
	if(!M || !(M.client && M.client.holder))
		..()
		return
	if(M.is_hulk())
		if(prob(40))
			boutput(M, "<span class='alert'><b>You smash the puny [src] apart!</b></span>")
			playsound(src, "shatter", 70, 1)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)

			for(var/mob/N in AIviewers(M, null))
				if(N == M)
					continue
				N.show_message("<span class='alert'><b>[M] smashes the [src] apart!</b></span>", 1)
			for(var/atom/A in src.contents)
				if(ismob(A))
					var/mob/N = A
					N.show_message("<span class='alert'><b>[M] smashes the [src] apart!</b></span>", 1)
					N.set_loc(src.loc)
				else if (isobj(A))
					var/obj/O = A
					O.set_loc(src.loc)
			var/obj/item/scrap/S = new
			S.size = 4
			S.update()
			qdel(src)
		else
			boutput(M, "<span class='alert'><b>You punch the puny [src]!</b></span>")
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
			for(var/mob/N in AIviewers(M, null))
				if(N == M)
					continue
				N.show_message("<span class='alert'><b>[M] punches the [src]!</b></span>", 1)
			for(var/atom/A in src.contents)
				if(ismob(A))
					var/mob/N = A
					N.show_message("<span class='alert'><b>[M] punches the [src]!</b></span>", 1)
	else
		playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
		if(rider && prob(40))
			playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
			src.visible_message("<span class='alert'><b>[M] has pulled [rider] out of the [src]!</b></span>", 1)
			rider.changeStatus("weakened", 2 SECONDS)
			eject_rider(0,0,0)
		else
			if(src.contents.len)
				playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
				src.visible_message("<span class='alert'><b>[M] opens up the [src], spilling the contents out!</b></span>", 1)
				for(var/atom/A in src.contents)
					if(ismob(A))
						var/mob/N = A
						N.show_message("<span class='alert'><b>You are let out of the [src] by [M]!</b></span>", 1)
						N.set_loc(src.loc)
					else if (isobj(A))
						var/obj/O = A
						O.set_loc(src.loc)
			else
				boutput(M, "<span class='notice'>There's nothing inside of the [src].</span>")
				return
	return

/obj/vehicle/adminbus/MouseDrop_T(mob/living/carbon/human/target, mob/user)
	if (!istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, target) > 0 || is_incapacitated(user) || isAI(user))
		return

	var/msg

	if(!(user.client && user.client.holder))
		boutput(user, "<span class='notice'>You don't feel cool enough to use the [src].</span>")
		return

	if(target == user && !user.stat)	// if drop self, then climbed in
		target.set_loc(src)
		if(rider)
			msg = "[user.name] climbs into the front of the [src]."
			boutput(user, "<span class='notice'>You climb into the front of the [src].</span>")
		else
			rider = target
			msg = "[user.name] climbs into the driver's seat of the [src]."
			boutput(user, "<span class='notice'>You climb into the driver's seat of the [src].</span>")
			rider.add_adminbus_powers()
			sleep(1 SECOND)
			handle_button_addition()
	else if(target != user && !user.restrained())
		target.set_loc(src)
		msg = "[user.name] stuffs [target.name] into the back of the [src]!"
		boutput(user, "<span class='notice'>You stuff [target.name] into the back of the [src]!</span>")
	else
		return
	for (var/mob/C in AIviewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)
	return

/obj/vehicle/adminbus/bump(atom/AM as mob|obj|turf)
	if(in_bump)
		return
	if(AM == rider || !rider)
		return
	if(!is_badmin_bus && ON_COOLDOWN(AM, "vehicle_bump", 10 SECONDS))
		return
	if(is_badmin_bus && ON_COOLDOWN(AM, "vehicle_bump", 5 SECONDS))
		return
	walk(src, 0)
	icon_state = nonmoving_state
	..()
	in_bump = 1
	if(isturf(AM))
		if(istype(AM, /turf/simulated/wall/r_wall || istype(AM, /turf/simulated/wall/auto/reinforced)) && prob(40))
			in_bump = 0
			return
		if(istype(AM, /turf/simulated/wall))
			var/turf/simulated/wall/T = AM
			T.dismantle_wall(1)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
			playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
			boutput(rider, "<span class='alert'><b>You crash through the wall!</b></span>")
			for(var/mob/C in viewers(src))
				shake_camera(C, 10, 16)
				if(C == rider)
					continue
				C.show_message("<span class='alert'><b>The [src] crashes through the wall!</b></span>", 1)
			in_bump = 0
			return
	if(ismob(AM))
		var/mob/M = AM
		boutput(rider, "<span class='alert'><b>You crash into [M]!</b></span>")
		for (var/mob/C in viewers(src))
			shake_camera(C, 8, 12)
			if(C == rider)
				continue
			C.show_message("<span class='alert'><b>The [src] crashes into [M]!</b></span>", 1)
		if(src.gib_onhit)
			M.gib()
		else
			M.changeStatus("stunned", 8 SECONDS)
			M.changeStatus("weakened", 5 SECONDS)
			var/turf/target = get_edge_target_turf(src, src.dir)
			M.throw_at(target, 10, 2)
		playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
		playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
		in_bump = 0
		return
	if(isobj(AM))
		var/obj/O = AM
		if(O.density)
			boutput(rider, "<span class='alert'><b>You crash into [O]!</b></span>")
			for (var/mob/C in viewers(src))
				shake_camera(C, 8, 12)
				if(C == rider)
					continue
				C.show_message("<span class='alert'><b>The [src] crashes into [O]!</b></span>", 1)
			var/turf/target = get_edge_target_turf(src, src.dir)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
			playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
			O.throw_at(target, 10, 2)
			if(istype(O, /obj/window) || istype(O, /obj/grille) || istype(O, /obj/machinery/door) || istype(O, /obj/structure/girder) || istype(O, /obj/foamedmetal))
				qdel(O)
			if(istype(O, /obj/critter))
				O:CritterDeath()
			if(!isnull(O) && is_badmin_bus)
				O:ex_act(2)
			in_bump = 0
			return
	in_bump = 0
	return

/obj/vehicle/adminbus/bullet_act(flag, A as obj)
	return

/obj/vehicle/adminbus/meteorhit()
	return

/obj/vehicle/adminbus/disposing()
	if(rider)
		boutput(rider, "<span class='alert'><b>Your [src] is destroyed!</b></span>")
		eject_rider(1)
	..()
	return

/obj/vehicle/adminbus/ex_act(severity)
	return

/obj/vehicle/adminbus/eject_rider(var/crashed, var/selfdismount, var/ejectall = 1)
	var/mob/living/rider = src.rider
	..()
	rider.remove_adminbus_powers()
	walk(src, 0)
	if(crashed)
		if(crashed == 2)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
		playsound(src.loc, "shatter", 40, 1)
		boutput(rider, "<span class='alert'><b>You are flung through the [src]'s windshield!</b></span>")
		rider.changeStatus("stunned", 8 SECONDS)
		rider.changeStatus("weakened", 5 SECONDS)
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><b>[rider] is flung through the [src]'s windshield!</b></span>", 1)
		var/turf/target = get_edge_target_turf(src, src.dir)
		rider.throw_at(target, 5, 1)
		if(prob(40) && length(src.contents))
			src.visible_message("<span class='alert'><b>Everything in the [src] flies out!</b></span>")
			for(var/atom/A in src.contents)
				if(ismob(A))
					var/mob/N = A
					N.show_message(text("<span class='alert'><b>You are flung out of the []!</b></span>", src), 1)
					N.set_loc(src.loc)
				else if (isobj(A))
					var/obj/O = A
					O.set_loc(src.loc)

	if(selfdismount)
		boutput(rider, "<span class='notice'>You climb out of the [src].</span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<b>[rider]</b> climbs out of the [src].", 1)

	rider = null
	src.icon_state = src.nonmoving_state
	if (src.is_badmin_bus)
		src.toggle_badmin()


/obj/vehicle/adminbus/attackby(var/obj/item/I, var/mob/user)
	if(!(user.client && user.client.holder))
		boutput(user, "<span class='notice'>You don't feel cool enough to use the [src].</span>")
		return

	var/obj/item/grab/G = I
	if(istype(G))	// handle grabbed mob
		if(ismob(G.affecting))
			var/mob/GM = G.affecting
			GM.set_loc(src)
			boutput(user, "<span class='notice'>You stuff [GM.name] into the back of the [src].</span>")
			boutput(GM, "<span class='alert'><b>[user] stuffs you into the back of the [src]!</b></span>")
			for (var/mob/C in AIviewers(src))
				if(C == user)
					continue
				C.show_message("<span class='alert'><b>[GM.name] has been stuffed into the back of the [src] by [user]!</b></span>", 3)
			qdel(G)
			return
	..()
	return

/obj/vehicle/adminbus/proc/do_darkness()
	if(prob(50))
		playsound(src.loc, 'sound/effects/ghost.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/effects/ghost2.ogg', 50, 1)

	var/list/apcs = bounds(src, 192)
	for(var/obj/machinery/power/apc/apc in apcs)
		if(prob(60))
			apc.overload_lighting()

	if(prob(50))
		gibs(get_turf(src))

/obj/vehicle/adminbus/proc/toggle_badmin()
	if (src.is_badmin_bus)
		src.name = initial(src.name)
		src.desc = initial(src.desc)
		src.moving_state = initial(src.moving_state)
		src.nonmoving_state = initial(src.nonmoving_state)
		src.is_badmin_bus = FALSE
		boutput(usr, "<span class='info'>Badmin mode disabled.</span>")
	else
		src.name = src.badmin_name
		src.desc = src.badmin_desc
		src.moving_state = src.badmin_moving_state
		src.nonmoving_state = src.badmin_nonmoving_state
		src.is_badmin_bus = TRUE
		boutput(usr, "<span class='info'>Badmin mode enabled.</span>")

/client/proc/toggle_gib_onhit()
	set category = "Adminbus"
	set name = "Toggle Gib On Collision"
	set desc = "Toggle gibbing when colliding with mobs."

	if(usr.stat)
		boutput(usr, "<span class='alert'>Not when you are incapacitated.</span>")
		return
	if(istype(usr.loc, /obj/vehicle/adminbus))
		var/obj/vehicle/adminbus/bus = usr.loc
		if(bus.gib_onhit)
			bus.gib_onhit = 0
			boutput(usr, "<span class='alert'>No longer gibbing on collision.</span>")
		else
			bus.gib_onhit = 1
			boutput(usr, "<span class='alert'>You will now gib mobs on collision. Let's paint the town red!</span>")
	else
		boutput(usr, "<span class='alert'>Uh-oh, you aren't in the adminbus! Report this.</span>")

/client/proc/toggle_badminbus()
	set category = "Adminbus"
	set name = "Toggle Badmin Mode"
	set desc = "Become the Badmin Bus"

	if(!isalive(usr))
		boutput(usr, "<span class='alert'>Not when you are incapacitated.</span>")
		return
	if(istype(usr.loc, /obj/vehicle/adminbus))
		var/obj/vehicle/adminbus/bus = usr.loc
		bus.toggle_badmin()
	else
		boutput(usr, "<span class='alert'>Uh-oh, you aren't in the adminbus! Report this.</span>")

/*
/atom/movable/effect/darkness
	icon = 'icons/effects/64x64.dmi'
	icon_state = "spooky"
	layer = EFFECTS_LAYER_BASE
	mouse_opacity = 0
	//blend_mode = BLEND_MULTIPLY

	New()
		..()
		src.Scale(9,9)
*/

/mob/proc/add_adminbus_powers()
	if(src.client.holder && src.client.holder.rank && src.client.holder.level >= LEVEL_PA)
		src.client.verbs += /client/proc/toggle_gib_onhit
		src.client.verbs += /client/proc/toggle_badminbus
	return

/mob/proc/remove_adminbus_powers()
	src.client.verbs -= /client/proc/toggle_gib_onhit
	src.client.verbs -= /client/proc/toggle_badminbus
	return

//////////////////////////////////////////////////////////////// Battle Bus //////////////////////////

/obj/vehicle/adminbus/battlebus
	name = "Battle Bus"
	desc = "A bus made for war."
	icon = 'icons/obj/battlebus.dmi'
	icon_state = "adminbus"
	moving_state = "adminbus2"
	nonmoving_state = "adminbus"
	badmin_moving_state = "adminbus2"
	badmin_nonmoving_state = "adminbus"
	badmin_name = "Baddler Bus"
	badmin_desc = "An unstoppable bus made for war."
	ability_buttons_to_initialize = list(/obj/ability_button/loudhorn, /obj/ability_button/stopthebus, /obj/ability_button/togglespook, /obj/ability_button/battlecannon, /obj/ability_button/omnicannon, /obj/ability_button/bombchute, /obj/ability_button/hotwheels, /obj/ability_button/staticcharge)
	var/datum/projectile/P = new/datum/projectile/special/spawner/battlecrate
	var/datum/projectile/special/spreader/uniform_burst/circle/P2 = new
	var/power_hotwheels = FALSE
	var/power_staticcharge = FALSE
	var/power_bomberbus = FALSE
	var/power_bomberbus_chance = 25
	var/power_bomberbus_type = /obj/bomberman

	New()
		..()

		P2.spread_projectile_type = /datum/projectile/fireball
		P2.pellets_to_fire = 10
		P2.pellet_shot_volume = 75 / P2.pellets_to_fire //anti-ear destruction

	do_special_on_relay(mob/user, dir) //this should probably actually be inside an overriden Move() proc, but I've preserved the original behavior here instead.
		icon_state = moving_state
		if(src.power_hotwheels)
			tfireflash(get_turf(src), 0, 100)
		if(src.power_staticcharge)
			elecflash(get_turf(src),radius=0, power=2, exclude_center = 0)
		if(src.power_bomberbus && prob(power_bomberbus_chance))
			new src.power_bomberbus_type(get_turf(src))
		return


/obj/ability_button/battlecannon
	name = "Battle Cannon"
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildmode4"

	Click(location, control, params)
		. = ..()
		if (!the_mob)
			return
		if(istype(the_mob.loc, /obj/vehicle/adminbus/battlebus))
			var/obj/vehicle/adminbus/battlebus/bus = usr.loc
			shoot_projectile_DIR(bus, bus.P, the_mob.dir)

/obj/ability_button/omnicannon
	name = "Omni Cannon"
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "pandemonium"

	Click(location, control, params)
		. = ..()
		if (!the_mob)
			return
		if(istype(the_mob.loc, /obj/vehicle/adminbus/battlebus))
			var/obj/vehicle/adminbus/battlebus/bus = usr.loc

			shoot_projectile_DIR(bus, bus.P2, NORTH)

/obj/ability_button/hotwheels
	name = "Hot Wheels"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "fire_e_sprint"

	Click(location, control, params)
		. = ..()
		if (!the_mob)
			return
		if(istype(the_mob.loc, /obj/vehicle/adminbus/battlebus))
			var/obj/vehicle/adminbus/battlebus/bus = usr.loc
			bus.power_hotwheels = !bus.power_hotwheels
			if (bus.power_hotwheels)
				boutput( the_mob, "<span class='alert'>Hot wheels engaged!</span>" )
			else
				boutput( the_mob, "<span class='alert'>Your tires begin to cooldown.</span>" )

/obj/ability_button/staticcharge
	name = "Static Charge"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "zzzap"

	Click(location, control, params)
		. = ..()
		if (!the_mob)
			return
		if(istype(the_mob.loc, /obj/vehicle/adminbus/battlebus))
			var/obj/vehicle/adminbus/battlebus/bus = usr.loc
			bus.power_staticcharge = !bus.power_staticcharge
			if (bus.power_staticcharge)
				boutput( the_mob, "<span class='alert'>The bus begins to tingle with static!</span>" )
			else
				boutput( the_mob, "<span class='alert'>The static charge disipates.</span>" )

/obj/ability_button/bombchute
	name = "Bomb Chute"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "fire_e_flamethrower"

	Click(location, control, params)
		. = ..()
		if (!the_mob)
			return
		if(istype(the_mob.loc, /obj/vehicle/adminbus/battlebus))
			var/obj/vehicle/adminbus/battlebus/bus = usr.loc
			bus.power_bomberbus = !bus.power_bomberbus
			if (bus.power_bomberbus)
				boutput( the_mob, "<span class='alert'>The bomb chute springs open!</span>" )
			else
				boutput( the_mob, "<span class='alert'>The bomb chute seals tightly shut.</span>" )

//////////////////////////////////////////////////////////////// Forklift //////////////////////////

TYPEINFO(/obj/vehicle/forklift)
	mats = 12

/obj/vehicle/forklift
	name = "forklift"
	desc = "A vehicle used to transport crates."
	icon_state = "forklift"
	anchored = ANCHORED
	health = 80
	health_max = 80
	var/list/helditems = list()	//Items being held by the forklift
	var/helditems_maximum = 3
	var/openpanel = 0			//1 when the back panel is opened
	var/broken = 0				//1 when the forklift is broken
	var/light = 0				//1 when the yellow light is on
	soundproofing = 5
	can_eject_items = TRUE
	var/image/image_light = null
	var/image/image_panel = null
	var/image/image_crate = null
	var/image/image_under = null
	attacks_fast_eject = 0
	delay = 2.5

/obj/vehicle/forklift/New()
	..()
	src.add_sm_light("forklift\ref[src]", list(0.5*255,0.5*255,0.5*255,255*0.67), directional = 1)

/obj/vehicle/forklift/examine()
	. = ..()
	var/list/examine_text = list()	//Shows who is driving it and also the items being carried
	var/obj/HI
	if(src.rider)
		examine_text += "[src.rider] is using it. "
	if(helditems.len >= 1)
		if (istype(helditems[1], /obj/))
			HI = helditems[1]
			examine_text += "It is carrying \a [HI.name]"
		if(helditems.len >= 2)
			for(var/i=2,i<=helditems.len-1,i++)
				if (istype(helditems[i], /obj/))
					HI = helditems[i]
					examine_text += ", [HI.name]"
			if (istype(helditems[helditems.len], /obj/))
				HI = helditems[helditems.len]
			examine_text += " and \a [HI.name]"
		examine_text += "."
	. += examine_text.Join("")

/obj/vehicle/forklift/verb/enter_forklift()
	set src in oview(1)
	set category = "Local"

	if (usr.stat)
		return

	if(!ishuman(usr))
		return

	if (src.rider)
		if(src.rider == usr)
			boutput(usr, "You are already in [src]!")
			return
		boutput(usr, "[src.rider] is using [src]!")
		return

	//if successful
	var/mob/M = usr
	M.set_loc(src)
	src.rider = M
	boutput(usr, "You get into [src].")
	src.update_overlays()
	return

/obj/vehicle/forklift/verb/exit_forklift()
	set src in oview(1)
	set category = "Local"

	if (usr.stat)
		return

	if (usr.loc != src)
		boutput(usr, "You aren't in [src]!")
		return

	//if successful
	eject_rider()
	return

/obj/vehicle/forklift/Click()
	//Click the forklift when inside it to get out
	if(src.rider != usr)
		..()
		return

	if (usr.stat)
		return

	eject_rider()
	return

/obj/vehicle/forklift/eject_rider(var/crashed, var/selfdismount, ejectall=TRUE)
	if (!src.rider)
		return

	var/mob/living/rider = src.rider
	..(ejectall = 0)

	boutput(rider, "You get out of [src].")

	//Stops items from being lost forever
	for (var/obj/item/I in src)
		if (I in helditems)
			continue
		I.set_loc(src.loc)

	for (var/mob/M in src)
		M.set_loc(src.loc)

	src.update_overlays()

//We, unfortunately, can't use the base relaymove here because the forklift has some
// special behaviors with overlays and underlays that produce weird behaviors
// (ghost riders, phantom crates) when combined with the base relaymove
/obj/vehicle/forklift/relaymove(mob/user as mob, direction)

	if (user.stat)
		return

	if (broken)
		return

	var/turf/T = get_turf(src)
	if(T.throw_unlimited && istype(T, /turf/space) && !src.booster_upgrade)
		return

	//forklift
	if(src.rider && user == src.rider)
		var/td = max(src.delay, MINIMUM_EFFECTIVE_DELAY)
		if (!src.booster_upgrade)
			if(T.throw_unlimited && istype(T, /turf/space))
				return
		src.glide_size = (32 / td) * world.tick_lag
		for(var/mob/M in src)
			M.glide_size = src.glide_size
			M.animate_movement = SYNC_STEPS
		if(src.booster_upgrade)
			src.UpdateOverlays(booster_image, "booster_image")
		walk(src, direction, td)
		src.glide_size = (32 / td) * world.tick_lag
		for(var/mob/M in src)
			M.glide_size = src.glide_size
			M.animate_movement = SYNC_STEPS
	else
		for(var/mob/M in src.contents)
			M.set_loc(src.loc)

/obj/vehicle/forklift/verb/toggle_lights()
	set category = "Forklift"
	set src = usr.loc

	if (usr.stat)
		return

	if (broken)
		boutput(usr, "You try to turn on the lights. Nothing happens.")

	if (!light)
		light = 1
		update_overlays()
		src.toggle_sm_light(1)
		return

	if (light)
		light = 0
		update_overlays()
		src.toggle_sm_light(0)
	return

/obj/vehicle/forklift/MouseDrop_T(atom/movable/A as obj|mob, mob/user as mob)

	if (user.stat)
		return

	//pick up crates with forklift
	if((istype(A, /obj/storage/crate) || istype(A, /obj/storage/cart) || istype(A, /obj/storage/secure/crate)) && BOUNDS_DIST(A, src) == 0 && src.rider == user && helditems.len != helditems_maximum && !broken)
		A.set_loc(src)
		helditems.Add(A)
		update_overlays()
		boutput(user, "<span class='notice'><b>You pick up the [A.name].</b></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='notice'><b>[src] picks up the [A.name].</b></span>", 1)
		return

	//Very funny
	if(istype(A, /obj/item/kitchen/utensil/fork))
		boutput(user, "You don't think [src] has enough utensil strength to pick this up.")
		return

	if(ishuman(A) && BOUNDS_DIST(user, src) == 0  && BOUNDS_DIST(A, user) == 0 && !rider)
		if (A == user)
			boutput(user, "You get into [src].")
		else
			boutput(user, "<span class='notice'>You help [A] onto [src]!</span>")
		A.set_loc(src)
		src.rider = A
		src.update_overlays()
		return

/obj/vehicle/forklift/attack_hand(mob/living/carbon/human/M)
	if(!M || !rider)
		..()
		return
	switch(M.a_intent)
		if("harm", "disarm")
			if(prob(40) || isunconscious(rider))
				playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
				src.visible_message("<span class='alert'><b>[M] has shoved [rider] off of [src]!</b></span>")
				if (!rider.hasStatus("weakened"))
					rider.changeStatus("weakened", 2 SECONDS)
					rider.force_laydown_standup()
				rider.set_loc(src.loc)
				src.rider = null
				src.update_overlays()
			else
				playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 25, 1, -1)
				src.visible_message("<span class='alert'><b>[M] has attempted to shove [rider] off of [src]!</b></span>")
	return

/obj/vehicle/forklift/verb/drop_crates()
	set category = "Forklift"
	set src = usr.loc

	if (usr.stat)
		return

	var/turf/T = get_turf(src)
	if(T.throw_unlimited && istype(T, /turf/space))
		return

	if(helditems.len >= 1)

		if(helditems.len == 1)
			var/obj/O = helditems[1]
			for (var/mob/C in AIviewers(src))
				C.show_message("<span class='notice'><b>[src] leaves the [O.name] on [src.loc].</b></span>", 1)
			boutput(usr, "<span class='notice'><b>You leave the [O.name] on [src.loc].</b></span>")
		if(helditems.len > 1)
			for (var/mob/C in AIviewers(src))
				C.show_message("<span class='notice'><b>[src] leaves [helditems.len] crates on [src.loc].</b></span>", 1)
			boutput(usr, "<span class='notice'><b>You leave [helditems.len] crates on [src.loc].</b></span>")

		for (var/obj/HI in helditems)
			HI.set_loc(src.loc)

	helditems.len = 0
	update_overlays()
	return

obj/vehicle/forklift/attackby(var/obj/item/I, var/mob/user)
	//Use screwdriver to open/close the forklift's back panel
	if (isscrewingtool(I))
		if (!openpanel)
			openpanel = 1
			boutput(user, "You unlock [src]'s panel with [I].")
			update_overlays()
			return

		if (openpanel)
			openpanel = 0
			boutput(user, "You lock [src]'s panel with [I].")
			update_overlays()
			return

	//Breaking the forklift
	if (issnippingtool(I))
		if (openpanel && !broken)
			boutput(user, "<span class='notice'>You cut [src]'s wires!<span>")
			new /obj/item/cable_coil/cut/small( src.loc )
			break_forklift()
		return

	//Repairing the forklift
	if (istype(I,/obj/item/cable_coil))
		if (openpanel && broken)
			var/obj/item/cable_coil/coil = I
			coil.use(5)
			boutput(user, "<span class='notice'>You replace [src]'s wires!</span>")
			broken = 0
			if (helditems_maximum < 4)
				helditems_maximum = 4
			return

	return ..() // attacking rider on forklift

/obj/vehicle/forklift/proc/break_forklift()
	broken = 1
	//break the light if it is on
	if (light)
		light = 0
		src.toggle_sm_light(0)
		update_overlays()

/obj/vehicle/forklift/proc/update_overlays()
	if (light)
		if (!src.image_light)
			src.image_light = image(src.icon, "forklift_light")
		src.UpdateOverlays(src.image_light, "light")
	else
		src.UpdateOverlays(null, "light")
	if (openpanel)
		if (!src.image_panel)
			src.image_panel = image(src.icon, "forklift_panel")
		src.UpdateOverlays(src.image_panel, "panel")
	else
		src.UpdateOverlays(null, "panel")
	if (helditems.len > 0)
		if (!src.image_crate)
			src.image_crate = image(src.icon, "forklift_crate")
		for (var/i=0, i < helditems.len, i++)
			if (i <= 1)
				image_crate.icon_state = "forklift_crate"
			else if (i >= 2 && i <= 4)
				image_crate.icon_state = "forklift_crate[i]"
			else
				image_crate.icon_state = "forklift_crate4"
			image_crate.pixel_y = 7*i
			if (i >= 3)
				image_crate.pixel_x = rand(-1,1)
			src.UpdateOverlays(src.image_crate, "crate[i]")
	else
		for (var/i=0, i < src.helditems_maximum, i++)
			src.UpdateOverlays(null, "crate[i]")
	if (src.rider)
		src.icon_state = "forklift1"
		src.underlays += rider
		if (!src.image_under)
			src.image_under = image(src.icon, "forklift")
		src.underlays += src.image_under
	else
		src.icon_state = "forklift"
		src.underlays = null

/obj/vehicle/forklift/bullet_act(flag, A as obj)
	if(rider && rider_visible)
		rider.bullet_act(flag, A)
		//do not eject!
	else
		..()
