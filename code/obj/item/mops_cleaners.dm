/*
CONTAINS:
SPACE CLEANER
MOP
SPONGES??
WET FLOOR SIGN

*/
/obj/item/spraybottle
	desc = "An unlabeled spray bottle."
	icon = 'icons/obj/janitor.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	name = "spray bottle"
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = ONBELT|TABLEPASS|OPENCONTAINER|FPRINT|EXTRADELAY|SUPPRESSATTACK
	var/rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	tooltip_flags = REBUILD_DIST | REBUILD_SPECTRO
	move_triggered = 1

/obj/item/spraybottle/move_trigger(var/mob/M, kindof)
	if (..() && reagents)
		reagents.move_trigger(M, kindof)

/obj/item/spraybottle/pixelaction(atom/target, params, mob/user, reach)
	..()
	return FALSE // this needs to be here for ranged clicking I think, I hate it

/obj/item/spraybottle/New()
	..()
	create_reagents(100)

/obj/item/spraybottle/detective
	name = "luminol bottle"
	desc = "A spray bottle labeled 'Luminol - Blood Detection Agent'. That's what those fancy detectives use to see blood!"

	New()
		..()
		reagents.add_reagent("luminol", 100)

	examine()
		. = ..()
		. += "[bicon(src)] [src.reagents.total_volume] units of luminol left!"

/obj/item/spraybottle/cleaner/
	name = "cleaner spray bottle"
	desc = "A spray bottle labeled 'Poo-b-Gone Space Cleaner'."

	New()
		..()
		reagents.add_reagent("cleaner", 100)

/obj/item/spraybottle/cleaner/robot
	name = "cybernetic cleaner spray bottle"
	desc = "A cleaner spray bottle jury-rigged to synthesize space cleaner."
	icon_state = "cleaner_robot"

	disposing()
		..()
		processing_items.Remove(src)

	afterattack(atom/A, mob/user)
		. = ..()
		if (src.reagents.total_volume < 25)
			processing_items |= src

	process()
		..()
		// starts with 100 cleaner but only autofills to 25. thanks, nanotrasen!
		if (src.reagents.total_volume < 25)
			src.reagents.add_reagent("cleaner", 1)
		else
			processing_items.Remove(src)
		return 0

/obj/janitorTsunamiWave
	name = "chemicals"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "tsunami"
	alpha = 175
	anchored = 1

	New(var/_loc, var/atom/target)
		..()
		set_loc(_loc)
		create_reagents(10)
		reagents.add_reagent("cleaner", 10)
		var/direction = get_dir_alt(src, target)
		if(direction == NORTHEAST || direction == NORTHWEST || direction == SOUTHEAST || direction == SOUTHWEST)
			direction = turn(direction, 45)
		switch(direction)
			if(NORTH)
				pixel_x = -32
			if(EAST)
				pixel_y = -32
			if(SOUTH)
				pixel_x = -32
				pixel_y = -64
			if(WEST)
				pixel_x = -64
				pixel_y = -32
		var/matrix/M = matrix()
		M = M.Scale(0,0)
		src.transform = M
		animate(src, transform=matrix(), time = 25, easing = ELASTIC_EASING)
		SPAWN_DBG(0)
			go(direction)

	proc/go(var/direction)
		src.set_dir(direction)
		clean(direction)
		for(var/i=0, i<10, i++)
			var/turf/T = get_step(src.loc, direction)
			if(!isnull(T))
				var/blocked = 0
				for(var/atom/movable/A in T)
					if(A.density && A.anchored && !ismob(A))
						blocked = 1
						break
				if(T.density || blocked)
					return vanish()
				else
					src.set_loc(T)
					clean(direction)
					src.set_dir(direction)
			sleep(0.2 SECONDS)
		vanish()
		return

	proc/vanish()
		animate(src, alpha = 0, time = 5)
		SPAWN_DBG(0.5 SECONDS)
			src.invisibility = 101
			src.set_loc(null)
			qdel(src)
		return

	proc/clean(var/direction)
		var/turf/left
		var/turf/right
		switch(direction)
			if(NORTH)
				left = locate(x-1,y,z)
				right = locate(x+1,y,z)
			if(EAST)
				left = locate(x,y+1,z)
				right = locate(x,y-1,z)
			if(SOUTH)
				left = locate(x+1,y,z)
				right = locate(x-1,y,z)
			if(WEST)
				left = locate(x,y-1,z)
				right = locate(x,y+1,z)

		var/list/affected = list(src.loc, left, right)
		for(var/turf/B in affected)
			reagents.reaction(B)
			for (var/atom/A in B)
				if (istype(A, /obj/overlay/tile_effect) || A.invisibility >= 100)
					continue
				reagents.reaction(A)
		return

/obj/item/spraybottle/cleaner/tsunami
	name = "Tsunami-P3 spray bottle"
	desc = "A highly over-engineered spray bottle with all kinds of actuators, pumps and matter-generators. Never runs out of cleaner and has a remarkable range."
	icon_state = "tsunami"
	item_state = "tsunami"
	var/lastUse = null

	afterattack(atom/A as mob|obj, mob/user as mob)
		if (istype(A, /obj/item/storage))
			return
		if (!isturf(user.loc))
			return

		if(lastUse)
			var/actual = (world.timeofday - lastUse)
			if(actual < 0) actual += 864000
			if(actual < 40) return

		lastUse = world.timeofday

		reagents.clear_reagents()
		reagents.add_reagent("cleaner", 100)

		if(src.reagents.has_reagent("water") || src.reagents.has_reagent("cleaner"))
			JOB_XP(user, "Janitor", 2)

		new/obj/janitorTsunamiWave(get_turf(src), A)
		playsound(src.loc, 'sound/effects/bigwave.ogg', 70, 1)

/obj/item/spraybottle/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/spraybottle/afterattack(atom/A as mob|obj, mob/user as mob)
	if (istype(A, /obj/item/storage))
		return
	if (!isturf(user.loc)) // Hi, I'm hiding in a closet like a wuss while spraying people with death chems risk-free.
		return
	if (src.reagents.total_volume < 1)
		boutput(user, "<span class='notice'>The spray bottle is empty!</span>")
		return

	if(src.reagents.has_reagent("water") || src.reagents.has_reagent("cleaner"))
		JOB_XP(user, "Janitor", 2)

	var/obj/decal/D = new/obj/decal(get_turf(src))
	D.name = "chemicals"
	D.icon = 'icons/obj/chemical.dmi'
	D.icon_state = "chempuff"
	D.create_reagents(5) // cogwerks: lowered from 10 to 5
	src.reagents.trans_to(D, 5)
	playsound(src.loc, "sound/effects/zzzt.ogg", 50, 1, -6)
	var/log_reagents = log_reagents(src)
	var/travel_distance = max(min(get_dist(get_turf(src), A), 3), 1)
	SPAWN_DBG(0)
		for (var/i=0, i<travel_distance, i++)
			step_towards(D,A)
			var/turf/theTurf = get_turf(D)
			D.reagents.reaction(theTurf)
			D.reagents.remove_any(1)
			for (var/atom/T in theTurf)
				if (istype(T, /obj/overlay/tile_effect) || T.invisibility >= 100)
					continue
				D.reagents.reaction(T)
				if (ismob(T))
					logTheThing("combat", user, T, "'s spray hits [constructTarget(T,"combat")] [log_reagents] at [log_loc(user)].")
				D.reagents.remove_any(1)
			if (!D.reagents.total_volume)
				break
			sleep(0.3 SECONDS)
		qdel(D)
	var/turf/logTurf = get_turf(D)
	logTheThing("combat", user, logTurf, "sprays [src] at [constructTarget(logTurf,"combat")] [log_reagents] at [log_loc(user)].")

	return

/obj/item/spraybottle/get_desc(dist, mob/user)
	if (dist > 2)
		return
	if (!reagents)
		return
	. = "<br><span class='notice'>[reagents.get_description(user,rc_flags)]</span>"
	return

// MOP

/obj/item/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "mop"
	var/mopping = 0
	var/mopcount = 0
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 10
	w_class = 3.0
	flags = FPRINT | TABLEPASS
	stamina_damage = 40
	stamina_cost = 15
	stamina_crit_chance = 10

/obj/item/mop/orange
	desc = "The world of janitalia wouldn't be complete without a mop. This one comes in orange!"
	name = "orange mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop_orange"
	item_state = "mop_orange"

/obj/item/mop/New()
	..()
	src.create_reagents(20)
	src.setItemSpecial(/datum/item_special/rangestab)
	START_TRACKING
	BLOCK_SETUP(BLOCK_ROD)

/obj/item/mop/disposing()
	. = ..()
	STOP_TRACKING

/obj/item/mop/examine()
	. = ..()
	if(reagents?.total_volume)
		. += "<span class='notice'>[src] is wet!</span>"

/obj/item/mop/afterattack(atom/A, mob/user as mob)
	if ((src.reagents.total_volume < 1 || mopcount >= 9) && !istype(A, /obj/fluid))
		boutput(user, "<span class='notice'>Your mop is dry!</span>", group = "mop")
		return

	if (istype(A, /turf/simulated) || istype(A, /obj/decal/cleanable) || istype(A, /obj/fluid))
		//user.visible_message("<span class='alert'><B>[user] begins to clean [A].</B></span>")
		actions.start(new/datum/action/bar/icon/mop_thing(src,A), user)
	return

/obj/item/mop/proc/clean(atom/A, mob/user as mob)
	var/turf/U = get_turf(A)
	JOB_XP(user, "Janitor", 2)
	playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)

	// Some people use mops for heat-delayed fireballs and stuff.
	// Mopping the floor with just water isn't of any interest, however (Convair880).
	if (src.reagents.total_volume && (!src.reagents.has_reagent("water") || (src.reagents.has_reagent("water") && src.reagents.reagent_list.len > 1)))
		logTheThing("combat", user, null, "mops [U && isturf(U) ? "[U]" : "[A]"] with chemicals [log_reagents(src)] at [log_loc(user)].")

	if (U && isturf(U))
		src.reagents.reaction(U,1,5)
		src.reagents.remove_any(5)
		mopcount++

	var/obj/fluid/target_fluid = A
	if (istype(target_fluid))
		if (src.reagents && target_fluid.group)
			target_fluid.group.drain(target_fluid,1,src)
		user.show_text("You soak up [target_fluid] with [src].", "blue", group = "mop")
		if (mopcount > 0)
			mopcount--
	else if (U && isturf(U))
		//U.clean_forensic()
		user.show_text("You have mopped up [A]!", "blue", group = "mop")
	else
		//A.clean_forensic()
		user.show_text("You have mopped up [A]!", "blue", group = "mop")

	if (mopcount >= 9) //Okay this stuff is an ugly hack and i feel bad about it.
		SPAWN_DBG(0.5 SECONDS)
			if (src?.reagents)
				src.reagents.clear_reagents()
				mopcount = 0

/obj/item/mop/attack_self(mob/user as mob)
	if (istype(user.loc, /obj/vehicle/segway))
		var/obj/vehicle/segway/S = user.loc
		if (S.joustingTool == src) // already raised as a lance, lower it
			user.visible_message("[user] lowers the jousting mop.", "You lower the mop. Everybody lets out a sigh of relief.")
			S.joustingTool = null
		else // Lances up!
			user.visible_message("[user] raises a mop as a lance!", "You raise the mop into jousting position.")
			S.joustingTool = src

/obj/item/mop/attack(mob/living/M as mob, mob/user as mob)
	if (user.intent == INTENT_HELP)
		user.visible_message("[user] pokes [M] with \the [src].", "You poke [M] with \the [src].")
		return
	return ..()

// Its the old mop. It makes floors slippery
/obj/item/mop/old
	name = "antique mop"
	desc = "This thing looks ancient, but it sure does get the job done!"

	afterattack(atom/A, mob/user as mob)
		if (src.reagents.total_volume < 1 || mopcount >= 5)
			boutput(user, "<span class='notice'>Your mop is dry!</span>")
			return

		if (istype(A, /turf) || istype(A, /obj/decal/cleanable))
			user.visible_message("<span class='alert'><B>[user] begins to clean [A]</B></span>")
			var/turf/U = get_turf(A)

			if (do_after(user, 4 SECONDS))
				if (get_dist(A, user) > 1)
					user.show_text("You were interrupted.", "red")
					return
				user.show_text("You have finished mopping!", "blue")
				playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)
				if (U && isturf(U))
					U.clean_forensic()
				else
					A.clean_forensic()
			else
				user.show_text("You were interrupted.", "red")
				return

			// Some people use mops for heat-delayed fireballs and stuff.
			// Mopping the floor with just water isn't of any interest, however (Convair880).
			if (src.reagents.total_volume && (!src.reagents.has_reagent("water") || (src.reagents.has_reagent("water") && src.reagents.reagent_list.len > 1)))
				logTheThing("combat", user, null, "mops [U && isturf(U) ? "[U]" : "[A]"] with chemicals [log_reagents(src)] at [log_loc(user)].")

			mopcount++

			if(istype(U,/turf/simulated))
				var/turf/simulated/T = U
				var/wetoverlay = image('icons/effects/water.dmi',"wet_floor")
				T.overlays += wetoverlay
				T.wet = 1
				SPAWN_DBG(30 SECONDS)
					if (istype(T))
						T.wet = 0
						T.overlays -= wetoverlay

		if (mopcount >= 5) //Okay this stuff is an ugly hack and i feel bad about it.
			SPAWN_DBG(0.5 SECONDS)
				if (src?.reagents)
					src.reagents.clear_reagents()
					mopcount = 0

		return

	clean(atom/A, mob/user as mob)
		var/turf/U = get_turf(A)
		JOB_XP(user, "Janitor", 2)
		playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)

		if (U && isturf(U))
			src.reagents.remove_any(5)
			mopcount++

		if (mopcount >= 9) //Okay this stuff is an ugly hack and i feel bad about it.
			SPAWN_DBG(0.5 SECONDS)
				if (src?.reagents)
					src.reagents.clear_reagents()
					mopcount = 0

// SPONGES? idk

/datum/reagents/sponge
	update_total()
		..()
		var/obj/item/sponge/S = src.my_atom
		if (S)
			var/size = 1
			if (src.total_volume > 0)
				size += (src.total_volume / src.maximum_volume) * 0.6
			sponge_size(S, size)
		return 0

/obj/item/sponge
	name = "sponge"
	desc = "After careful analysis, you've come to the conclusion that the strange object is, in fact, a sponge."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "sponge"
	item_state = "sponge"
	force = 0
	throwforce = 0
	w_class = 2 // gross why would you put a sponge in your pocket

	var/hit_face_prob = 30 // MODULAR SPONGES
	var/spam_flag = 0 // people spammed snapping their fucking fingers, so this is probably necessary

/obj/item/sponge/New()
	..()
	// We use this instead of create_reagents because sponges need a special reagent holder to grow in size
	reagents = new/datum/reagents/sponge(50)
	reagents.my_atom = src
	processing_items |= src

/obj/item/sponge/disposing()
	processing_items -= src
	..()

/obj/item/sponge/examine()
	. = ..()
	if(reagents?.total_volume)
		. += "<span class='notice'>[src] is wet!</span>"

/obj/item/sponge/attack_self(mob/user as mob)
	if(spam_flag)
		return
	var/turf/location = get_turf(user)
	user.visible_message("<span class='notice'>[user] wrings out [src].</span>")
	spam_flag = 1
	if (location)
		src.reagents.reaction(location, TOUCH, src.reagents.total_volume)
	//somepotato note: wtf is the thing below this
	//mbc note : yeah that's dumb! I moved spam_flag up top to prevent reagent duplication
	SPAWN_DBG(1 DECI SECOND) // to make sure the reagents actually react before they're cleared
	src.reagents.clear_reagents()
	SPAWN_DBG(1 SECOND)
	spam_flag = 0

/obj/item/sponge/attackby(obj/item/W as obj, mob/user as mob)
	if (istool(W, TOOL_CUTTING | TOOL_SNIPPING))
		user.visible_message("<span class='notice'>[user] cuts [src] into the shape of... cheese?</span>")
		if(src.loc == user)
			user.u_equip(src)
		src.set_loc(user)
		var/obj/item/sponge/cheese/I = new /obj/item/sponge/cheese
		src.reagents.trans_to(I, reagents.total_volume)
		user.put_in_hand_or_drop(I)
		qdel(src)

/obj/item/sponge/throw_impact(atom/hit, datum/thrown_thing/thr)
	if(hit && ishuman(hit))
		if(prob(hit_face_prob))
			var/mob/living/carbon/human/DUDE = hit
			hit.visible_message("<span class='alert'><b>[src] hits [DUDE] squarely in the face!</b></span>")
			playsound(DUDE.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			if(DUDE.wear_mask || (DUDE.head && DUDE.head.c_flags & COVERSEYES))
				boutput(DUDE, "<span class='alert'>Your headgear protects you! PHEW!!!</span>")
				SPAWN_DBG(1 DECI SECOND) src.reagents.clear_reagents()
				return
			src.reagents.reaction(DUDE, TOUCH)
			src.reagents.trans_to(DUDE, reagents.total_volume)
			SPAWN_DBG(1 DECI SECOND) src.reagents.clear_reagents()
	..()


/obj/item/sponge/process()
	if (!src.reagents) return
	if (!istype(src.loc,/turf/simulated/floor)) return
	if (src.reagents && src.reagents.total_volume >= src.reagents.maximum_volume) return
	var/turf/simulated/floor/T = src.loc
	if (T.active_liquid && T.active_liquid.group)
		T.active_liquid.group.drain(T.active_liquid,1,src)

/obj/item/sponge/afterattack(atom/target, mob/user as mob)
	if (!src.reagents)
		return ..()

	if (!isarea(target))
		var/list/choices = list()
		var/target_is_fluid = istype(target,/obj/fluid)
		if (target_is_fluid)
			choices += "Soak up"
		else if (istype(target, /turf/simulated))
			var/turf/simulated/T = target
			if (T.reagents && T.reagents.total_volume || T.active_liquid)
				choices += "Soak up"
			if (T.wet)
				choices += "Dry"
			if (src.reagents.total_volume)
				choices += "Wipe down"
		if (src.reagents.total_volume && !target_is_fluid)
			choices += "Wipe down"
			if ((istype(target, /obj/item/reagent_containers/glass) && target.is_open_container()) || istype(target, /obj/machinery/bathtub) || istype(target, /obj/submachine/chef_sink) || istype(target, /obj/mopbucket))
				choices += "Wring out"
		if (src.reagents.total_volume < src.reagents.maximum_volume && ((istype(target, /obj/item/reagent_containers/glass) && target.is_open_container()) || istype(target, /obj/machinery/bathtub) || istype(target, /obj/submachine/chef_sink)) || istype(target, /obj/mopbucket))
			if (istype(target, /obj/submachine/chef_sink) || (target.reagents && target.reagents.total_volume))
				choices += "Wet"

		if (!choices.len)
			boutput(user, "<span class='notice'>You can't think of anything to do with [src].</span>")
			return

		var/selection
		if (choices.len == 1) // at spy's request the sponge will default to the only thing it can do ARE YOU HAPPY NOW SPY
			selection = choices[1]
		else
			selection = input(user, "What do you want to do with [src]?", "Selection") as null|anything in choices
		if (isnull(selection) || user.equipped() != src || get_dist(user, target) > 1)
			return

		switch (selection)
			if ("Soak up")
				if (src.reagents.total_volume >= src.reagents.maximum_volume)
					user.show_text("[src] is full! Wring it out first.", "blue")
					return

				var/turf/T = target
				var/obj/fluid/F = target

				if (!F && T?.active_liquid)
					F = T.active_liquid

				if (!(T?.reagents) && !istype(F)) return

				if (F)
					if (F.group)
						F.group.drain(F,1,src)
					else
						F.removed()
					user.visible_message("[user] soaks up [F] with [src].",\
					"<span class='notice'>You soak up [F] with [src].</span>")
				else
					target.reagents.trans_to(src, 15)
					user.visible_message("[user] soaks up the mess on [target] with [src].",\
					"<span class='notice'>You soak up the mess on [target] with [src].</span>")

				JOB_XP(user, "Janitor", 1)
				return

			if ("Dry")
				if (!istype(target, /turf/simulated)) // really, how?? :I
					return
				var/turf/simulated/T = target
				user.visible_message("[user] dries up [T] with [src].",\
				"<span class='notice'>You dry up [T] with [src].</span>")
				JOB_XP(user, "Janitor", 1)
				src.reagents.add_reagent("water", rand(5,15))
				T.wet = 0
				return

			if ("Wipe down")
				user.visible_message("[user] wipes down [target] with [src].",\
				"<span class='notice'>You wipe down [target] with [src].</span>")
				if (src.reagents.has_reagent("water"))
					target.clean_forensic()
				src.reagents.reaction(target, TOUCH, 5)
				src.reagents.remove_any(5)
				JOB_XP(user, "Janitor", 3)
				if (target.reagents)
					target.reagents.trans_to(src, 5)
				return

			if ("Wring out")
				user.visible_message("<span class='alert'>[user] wrings [src] out into [target].</span>")
				if (target.reagents)
					src.reagents.trans_to(target, src.reagents.total_volume)
				return

			if ("Wet")
				var/fill_amt = (src.reagents.maximum_volume - src.reagents.total_volume)
				user.visible_message("<span class='alert'>[user] wets [src] in [target].</span>")
				if (target.reagents)
					target.reagents.trans_to(src, fill_amt)
				else
					src.reagents.add_reagent("water", fill_amt)
					JOB_XP(user, "Janitor", 1)
				return
	else
		..()

/obj/item/sponge/cheese
	name = "cheese-shaped sponge"
	desc = "Wait a minute! This isn't cheese..."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "sponge-cheese"
	item_state = "sponge"


/obj/item/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "caution"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS
	stamina_damage = 15
	stamina_cost = 4
	stamina_crit_chance = 10

	New()
		..()
		BLOCK_SETUP(BLOCK_SOFT)

	dropped()
		JOB_XP(usr, "Janitor", 2)
		return

	attackby(obj/item/W, mob/user, params)
		if(iswrenchingtool(W))
			actions.start(new /datum/action/bar/icon/anchor_or_unanchor(src, W, duration=2 SECONDS), user)
			return
		. = ..()

/obj/item/caution/traitor
	event_handler_flags = USE_PROXIMITY | USE_FLUID_ENTER
	var/obj/item/reagent_containers/payload

	New()
		. = ..()
		payload = new /obj/item/reagent_containers/glass/bucket/red(src)
		payload.reagents.add_reagent("superlube", payload.reagents.maximum_volume)
		src.create_reagents(1)

	attackby(obj/item/W, mob/user, params)
		var/mob/living/carbon/human/H = user
		if(istype(W, /obj/item/reagent_containers) && istype(H) && istype(H.gloves, /obj/item/clothing/gloves/long))
			boutput(user, "<span class='notice'>You stealthily replace the hidden [payload.name] with [W].</span>")
			user.drop_item(W)
			src.payload.set_loc(src.loc)
			user.put_in_hand_or_drop(src.payload)
			src.payload = W
			W.set_loc(src)
			return
		. = ..()

	HasProximity(atom/movable/AM)
		if(iscarbon(AM) && isturf(src.loc) && prob(20) && !ON_COOLDOWN(src, "spray", 3 SECONDS) && src.payload?.reagents)
			if(ishuman(AM))
				var/mob/living/carbon/human/H = AM
				if(istype(H.shoes, /obj/item/clothing/shoes/galoshes))
					return
			var/turf/T = AM.loc
			src.payload.reagents.trans_to(src, 1)
			src.reagents.reaction(T)
			src.reagents.clear_reagents()
		else
			. = ..()


/obj/item/holoemitter
	name = "Holo-emitter"
	desc = "A compact holo emitter pre-loaded with various holographic signs. Fits into pockets and boxes."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "emitter-off"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	throw_pixel = 0
	throw_spin = 0
	var/currentSelection = "wet"
	var/ownerKey = null
	anchored = 0

	attack_hand(mob/user)
		if(user.key != ownerKey && ownerKey != null)
			boutput(user, "<span style='color: red; font-weight: bold'>The [src.name] makes a grumpy buzzing sound and delivers a small electric shock! You drop it.</span>")
			return
		..()

	pull(var/mob/user)
		if (!istype(user))
			return
		if(user.key != ownerKey && ownerKey != null)
			boutput(user, "<span style='color: red; font-weight: bold'>The [src.name] makes a grumpy buzzing sound and delivers a small electric shock! You drop it.</span>")
			return
		return ..()

	attack_self(mob/user as mob)
		switch(currentSelection)
			if("wet")
				currentSelection = "cone"
			if("cone")
				currentSelection = "spray"
			if("spray")
				currentSelection = "text"
			if("text")
				currentSelection = "wet"
		boutput(user, "Set to '[currentSelection]'")

	set_loc(var/atom/movable/_loc)
		if(_loc)
			if(!isturf(src.loc) && isturf(_loc)) //From inside somewhere to outside on floor
				icon_state = "emitter-on"
				var/obj/holosign/H = new/obj/holosign(_loc)
				H.icon_state = "holo-[currentSelection]"
				attached_objs = list(H)
				pixel_y = 0
			else if(isturf(src.loc) && !isturf(_loc)) //From floor into something
				if(isobj(_loc) && isturf(_loc.loc))
					_loc = src.loc
					pixel_y = 0
				else
					icon_state = "emitter-off"
					pixel_y = 16
					if(attached_objs)
						for(var/atom/A in attached_objs)
							attached_objs -= A
							qdel(A)
		. = ..(_loc)
		pixel_x = 0


	dropped()
		JOB_XP(usr, "Janitor", 2)
		return

/obj/holosign
	desc = "..."
	name = "Hologram"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "holo-wet"
	alpha = 230
	pixel_y = 16
	anchored = 1
	layer = EFFECTS_LAYER_BASE
	var/datum/light/light
	var/obj/holoparticles/particles

	New(var/_loc)
		set_loc(_loc)

		light = new /datum/light/point
		light.attach(src)
		light.set_color(0.50, 0.60, 0.94)
		light.set_brightness(0.7)
		light.enable()

		SPAWN_DBG(1 DECI SECOND)
			animate(src, alpha=180, color="#DDDDDD", time=7, loop=-1)
			animate(alpha=230, color="#FFFFFF", time=1)
			animate(src, pixel_y=10, time=15, flags=ANIMATION_PARALLEL, easing=SINE_EASING, loop=-1)
			animate(pixel_y=16, easing=SINE_EASING, time=15)

		particles = new/obj/holoparticles(src.loc)
		attached_objs = list(particles)
		..(_loc)

	disposing()
		if(particles)
			particles.invisibility = 101
			qdel(particles)
		..()

/obj/holoparticles
	desc = ""
	name = ""
	icon = 'icons/obj/janitor.dmi'
	icon_state = "holoparticles"
	anchored = 1
	alpha= 230
	pixel_y = 14
	layer = EFFECTS_LAYER_BASE
