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
	w_class = W_CLASS_SMALL
	throw_speed = 2
	throw_range = 10
	tooltip_flags = REBUILD_DIST | REBUILD_SPECTRO
	move_triggered = 1
	var/initial_volume = 100

/obj/item/spraybottle/move_trigger(var/mob/M, kindof)
	if (..() && reagents)
		reagents.move_trigger(M, kindof)

/obj/item/spraybottle/pixelaction(atom/target, params, mob/user, reach)
	..()
	return FALSE // this needs to be here for ranged clicking I think, I hate it

/obj/item/spraybottle/New()
	..()
	create_reagents(initial_volume)

/obj/item/spraybottle/detective
	name = "luminol bottle"
	desc = "A spray bottle labeled 'Luminol - Blood Detection Agent'. That's what those fancy detectives use to see blood!"
	rc_flags = RC_VISIBLE | RC_SPECTRO | RC_SCALE

	New()
		..()
		reagents.add_reagent("luminol", initial_volume)

/obj/item/spraybottle/cleaner/
	name = "cleaner spray bottle"
	desc = "A spray bottle labeled 'Poo-b-Gone Space Cleaner'."

	New()
		..()
		reagents.add_reagent("cleaner", initial_volume)

/obj/item/spraybottle/cleaner/robot
	name = "cybernetic cleaner spray bottle"
	desc = "A cleaner spray bottle jury-rigged to synthesize space cleaner."
	icon_state = "cleaner_robot"
	var/refill_speed = 2.5
	initial_volume = 50
	disposing()
		..()
		processing_items.Remove(src)

	on_reagent_change()
		..()
		if (src.reagents.total_volume < src.reagents.maximum_volume)
			processing_items |= src

	process()
		..()
		if (src.reagents.total_volume < src.reagents.maximum_volume)
			src.reagents.add_reagent("cleaner", refill_speed)
		else
			processing_items.Remove(src)
		return 0

/obj/item/spraybottle/cleaner/robot/drone
	name = "cybernetic cleaning spray bottle"
	desc = "A small spray bottle that slowly synthesises space cleaner."
	icon_state = "cleaner_robot"
	initial_volume = 25
	refill_speed = 0.75

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
		var/direction = src.dir
		if(target)
			direction = get_dir_alt(src, target)
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
		SPAWN(0)
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
		SPAWN(0.5 SECONDS)
			src.invisibility = INVIS_ALWAYS
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
				if (istype(A, /obj/overlay/tile_effect) || A.invisibility >= INVIS_ALWAYS_ISH)
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

/obj/item/spraybottle/attack(mob/living/carbon/human/M, mob/user)
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
	playsound(src.loc, 'sound/effects/zzzt.ogg', 50, 1, -6)
	// Make sure we clean an item that was sprayed directly in case it is in contents
	if (!isturf(A.loc))
		if (istype(A, /obj/item))
			src.reagents.reaction(A, TOUCH, 5)
			src.reagents.remove_any(5)
			return
	var/obj/decal/D = new/obj/decal(get_turf(src))
	D.name = "chemicals"
	D.icon = 'icons/obj/chemical.dmi'
	D.icon_state = "chempuff"
	D.create_reagents(5) // cogwerks: lowered from 10 to 5
	src.reagents.trans_to(D, 5)
	var/log_reagents = log_reagents(src)
	var/travel_distance = clamp(GET_DIST(get_turf(src), A), 1, 3)
	SPAWN(0)
		for (var/i=0, i<travel_distance, i++)
			step_towards(D,A)
			var/turf/theTurf = get_turf(D)
			D.reagents.reaction(theTurf, react_volume=1)
			D.reagents.remove_any(1)
			for (var/atom/T in theTurf)
				if (istype(T, /obj/overlay/tile_effect) || T.invisibility >= INVIS_ALWAYS_ISH || D==T)
					continue
				D.reagents.reaction(T, react_volume=1)
				if (ismob(T))
					logTheThing(LOG_COMBAT, user, "'s spray hits [constructTarget(T,"combat")] [log_reagents] at [log_loc(user)].")
				D.reagents.remove_any(1)
			if (!D.reagents.total_volume)
				break
			sleep(0.3 SECONDS)
		qdel(D)
	var/turf/logTurf = get_turf(D)
	logTheThing(LOG_COMBAT, user, "sprays [src] at [constructTarget(logTurf,"combat")] [log_reagents] at [log_loc(user)].")

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
	desc = "The world of janitorial paraphernalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "mop"
	var/mopping = 0
	var/mopcount = 0
	force = 3
	throwforce = 10
	throw_speed = 5
	throw_range = 10
	w_class = W_CLASS_NORMAL
	flags = FPRINT | TABLEPASS
	stamina_damage = 40
	stamina_cost = 15
	stamina_crit_chance = 10

/obj/item/mop/orange
	desc = "The world of janitorial paraphernalia wouldn't be complete without a mop. This one comes in orange!"
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

/obj/item/mop/afterattack(atom/A, mob/user as mob)// the main utility of all moppage and mopkind
	if (ismob(A))
		return
	if ((src.reagents.total_volume < 1 || mopcount >= 9) && !istype(A, /obj/fluid))
		boutput(user, "<span class='notice'>Your mop is dry!</span>", group = "mop")
		return

	if(istype(A, /obj/fluid/airborne)) // no mopping up smoke
		var/turf/T = get_turf(A)
		if(T.active_liquid)
			A = T.active_liquid
		else
			A = T
	if (istype(A, /turf/simulated) || istype(A, /obj/decal/cleanable) || istype(A, /obj/fluid))
		//user.visible_message("<span class='alert'><B>[user] begins to clean [A].</B></span>")
		actions.start(new/datum/action/bar/icon/mop_thing(src,A), user)
	return

/obj/item/mop/proc/clean(atom/A, mob/user as mob)
	var/turf/U = get_turf(A)
	JOB_XP(user, "Janitor", 2)
	playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)

	// Some people use mops for heat-delayed fireballs and stuff.
	// Mopping the floor with just water isn't of any interest, however (Convair880).
	if (src.reagents.total_volume && (!src.reagents.has_reagent("water") || (src.reagents.has_reagent("water") && src.reagents.reagent_list.len > 1)))
		logTheThing(LOG_COMBAT, user, "mops [U && isturf(U) ? "[U]" : "[A]"] with chemicals [log_reagents(src)] at [log_loc(user)].")

	if (U && isturf(U))
		src.reagents.reaction(U,1,5)
		src.reagents.remove_any(5)
		mopcount++

	var/obj/fluid/target_fluid = A
	if (istype(target_fluid))
		user.show_text("You soak up [target_fluid] with [src].", "blue", group = "mop")
		if (src.reagents && target_fluid.group)
			target_fluid.group.drain(target_fluid,1,src)
		if (mopcount > 0)
			mopcount--
	else if (U && isturf(U))
		//U.clean_forensic()
		user.show_text("You have mopped up [A]!", "blue", group = "mop")
	else
		//A.clean_forensic()
		user.show_text("You have mopped up [A]!", "blue", group = "mop")

	if (mopcount >= 9) //Okay this stuff is an ugly hack and i feel bad about it.
		SPAWN(0.5 SECONDS)
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
	else
		for (var/obj/fluid/fluid in user.loc)
			src.AfterAttack(fluid, user)
			return
		if (isturf(user.loc))
			src.AfterAttack(user.loc, user)

/obj/item/mop/attack(mob/living/M, mob/user)
	if (user.a_intent == INTENT_HELP)
		user.visible_message("[user] pokes [M] with \the [src].", "You poke [M] with \the [src].")
		return
	return ..()

// Its the old mop. It makes floors slippery
/obj/item/mop/old
	name = "antique mop"
	icon_state = "mop_old"
	item_state = "mop_old"
	desc = "This thing looks ancient, but it sure does get the job done!"

	afterattack(atom/A, mob/user as mob)
		if (src.reagents.total_volume < 1 || mopcount >= 5)
			boutput(user, "<span class='notice'>Your mop is dry!</span>")
			return

		if (istype(A, /turf) || istype(A, /obj/decal/cleanable))
			user.visible_message("<span class='alert'><B>[user] begins to clean [A]</B></span>")
			var/turf/U = get_turf(A)

			if (do_after(user, 4 SECONDS))
				if (BOUNDS_DIST(A, user) > 0)
					user.show_text("You were interrupted.", "red")
					return
				user.show_text("You have finished mopping!", "blue")
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
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
				logTheThing(LOG_COMBAT, user, "mops [U && isturf(U) ? "[U]" : "[A]"] with chemicals [log_reagents(src)] at [log_loc(user)].")

			mopcount++

			if(istype(U,/turf/simulated))
				var/turf/simulated/T = U
				var/wetoverlay = image('icons/effects/water.dmi',"wet_floor")
				T.overlays += wetoverlay
				T.wet = 1
				SPAWN(30 SECONDS)
					if (istype(T))
						T.wet = 0
						T.overlays -= wetoverlay

		if (mopcount >= 5) //Okay this stuff is an ugly hack and i feel bad about it.
			SPAWN(0.5 SECONDS)
				if (src?.reagents)
					src.reagents.clear_reagents()
					mopcount = 0

		return

	clean(atom/A, mob/user as mob)
		var/turf/U = get_turf(A)
		JOB_XP(user, "Janitor", 2)
		playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)

		if (U && isturf(U))
			src.reagents.remove_any(5)
			mopcount++

		if (mopcount >= 9) //Okay this stuff is an ugly hack and i feel bad about it.
			SPAWN(0.5 SECONDS)
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
	stamina_damage = 5
	throwforce = 0
	w_class = W_CLASS_SMALL // gross why would you put a sponge in your pocket

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

/obj/item/sponge/attack(mob/living/M, mob/user)
	if (user.a_intent == INTENT_HELP)
		return
	return ..()

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
	SPAWN(1 DECI SECOND) // to make sure the reagents actually react before they're cleared
	src.reagents.clear_reagents()
	SPAWN(1 SECOND)
	spam_flag = 0

/obj/item/sponge/attackby(obj/item/W, mob/user)
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
			playsound(DUDE.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
			if(DUDE.wear_mask || (DUDE.head && DUDE.head.c_flags & COVERSEYES))
				boutput(DUDE, "<span class='alert'>Your headgear protects you! PHEW!!!</span>")
				SPAWN(1 DECI SECOND) src.reagents.clear_reagents()
				return
			src.reagents.reaction(DUDE, TOUCH)
			src.reagents.trans_to(DUDE, reagents.total_volume)
			SPAWN(1 DECI SECOND) src.reagents.clear_reagents()
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

	if(istype(target, /obj/fluid/airborne)) // no sponging up smoke
		target = get_turf(target)
	if (!isarea(target))
		var/list/choices = list()
		var/target_is_fluid = istype(target,/obj/fluid)
		if (target_is_fluid)
			choices |= "Soak up"
		else if (istype(target, /turf/simulated))
			var/turf/simulated/T = target
			if (T.reagents && T.reagents.total_volume || T.active_liquid)
				choices |= "Soak up"
			if (T.wet)
				choices |= "Dry"
			if (src.reagents.total_volume)
				choices |= "Wipe down"
		if (src.reagents.total_volume && !target_is_fluid)
			choices |= "Wipe down"
			if ((istype(target, /obj/item/reagent_containers/glass) && target.is_open_container()) || istype(target, /obj/machinery/bathtub) || istype(target, /obj/submachine/chef_sink) || istype(target, /obj/mopbucket))
				choices |= "Wring out"
		if (src.reagents.total_volume < src.reagents.maximum_volume && ((istype(target, /obj/item/reagent_containers/glass) && target.is_open_container()) || istype(target, /obj/machinery/bathtub) || istype(target, /obj/submachine/chef_sink)) || istype(target, /obj/mopbucket))
			if (istype(target, /obj/submachine/chef_sink) || (target.reagents && target.reagents.total_volume))
				choices |= "Wet"

		if (!choices.len)
			boutput(user, "<span class='notice'>You can't think of anything to do with [src].</span>")
			return

		var/selection
		if (choices.len == 1) // at spy's request the sponge will default to the only thing it can do ARE YOU HAPPY NOW SPY
			selection = choices[1]
		else
			selection = input(user, "What do you want to do with [src]?", "Selection") as null|anything in choices
		if (isnull(selection) || user.equipped() != src || BOUNDS_DIST(user, target) > 0)
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

				if (!(T?.reagents) && !istype(F))
					return

				if (F)
					if (F.group)
						F.group.drain(F,1,src)
					else
						F.removed()
					user.visible_message("[user] soaks up [F] with [src].",\
					"<span class='notice'>You soak up [F] with [src].</span>", group="soak")
				else
					target.reagents.trans_to(src, 15)
					user.visible_message("[user] soaks up the mess on [target] with [src].",\
					"<span class='notice'>You soak up the mess on [target] with [src].</span>", group="soak")

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
				target.remove_filter(list("paint_color", "paint_pattern"))
				playsound(src, 'sound/items/sponge.ogg', 20, 1)
				if (ismob(target))
					animate_smush(target)
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
/obj/item/sponge/ghostdronesafe
	name = "Integrated sponge"
	desc = "A cleaning utensil with an associated drainage system to prevent excess fluids from dripping when wrung out."

/obj/item/sponge/ghostdronesafe/attack_self(mob/user as mob)
	if (ON_COOLDOWN(user, "ghostdrone sponge wringing", 5 SECONDS))// Wtihout the cooldown, this is stupid powerful
		boutput(user, "<span class='notice'> The [src] is still processing fluids, please wait!</span>")
		return
	user.visible_message("<span class='notice'>[user] drains the [src].</span>")
	src.reagents.clear_reagents()

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
	force = 1
	throwforce = 3
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
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
		payload.reagents.add_reagent("invislube", payload.reagents.maximum_volume)
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
	force = 1
	throwforce = 3
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
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

	pull(mob/user)
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
	var/obj/holoparticles/holoparticles

	New(var/_loc)
		set_loc(_loc)

		light = new /datum/light/point
		light.attach(src)
		light.set_color(0.5, 0.6, 0.94)
		light.set_brightness(0.7)
		light.enable()

		SPAWN(1 DECI SECOND)
			animate(src, alpha=180, color="#DDDDDD", time=7, loop=-1)
			animate(alpha=230, color="#FFFFFF", time=1)
			animate(src, pixel_y=10, time=15, flags=ANIMATION_PARALLEL, easing=SINE_EASING, loop=-1)
			animate(pixel_y=16, easing=SINE_EASING, time=15)

		holoparticles = new/obj/holoparticles(src.loc)
		attached_objs = list(holoparticles)
		..(_loc)

	disposing()
		if(holoparticles)
			holoparticles.invisibility = INVIS_ALWAYS
			qdel(holoparticles)
			holoparticles = null
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


// handheld vacuum

/obj/item/handheld_vacuum
	name = "handheld vacuum"
	desc = "Sucks smoke. Sucks small items. Sucks just in general!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "handvac"
	mats = list("bamboo"=3, "MET-1"=10)
	health = 7
	w_class = W_CLASS_SMALL
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK
	item_function_flags = USE_SPECIALS_ON_ALL_INTENTS
	var/obj/item/reagent_containers/glass/bucket/bucket
	var/obj/item/clothing/under/trash_bag/trashbag

	New()
		..()
		src.setItemSpecial(/datum/item_special/suck)
		src.bucket = new(src)
		src.trashbag = new(src)

	get_desc(dist, mob/user)
		. = ..()
		if(src.trashbag)
			. += "<br>It contains \the [src.trashbag]. [src.trashbag.get_desc(dist, user)]"
		else
			. += "<br>The trashbag is missing."
		if(src.bucket)
			. += "<br>It contains \the [src.bucket]. [src.bucket.get_desc(dist, user)]"
		else
			. += "<br>The bucket is missing."

	attack_self(mob/user)
		. = ..()
		var/list/removed_things = list()
		if(src.trashbag)
			removed_things += src.trashbag
			src.trashbag.set_loc(user.loc)
			user.put_in_hand_or_drop(src.trashbag)
			src.trashbag = null
		if(src.bucket)
			removed_things += src.bucket
			src.bucket.set_loc(user.loc)
			user.put_in_hand_or_drop(src.bucket)
			src.bucket = null
		if(length(removed_things) == 0)
			boutput(user, "<span class='notice'>\The [src] has no bucket nor trashbag.</span>")
		else if(length(removed_things) == 1)
			boutput(user, "<span class='notice'>You remove \the [removed_things[1]] from \the [src]</span>")
		else
			boutput(user, "<span class='notice'>You remove \the [removed_things[1]] and \the [removed_things[2]] from \the [src]</span>")
		src.tooltip_rebuild = 1

	attack_hand(mob/user)
		if(!(src.loc == user && user.find_in_hand(src)))
			. = ..()
		else if(src.trashbag)
			src.trashbag.set_loc(user.loc)
			user.put_in_hand_or_drop(src.trashbag)
			boutput(user, "<span class='notice'>You remove \the [src.trashbag] from \the [src]</span>")
			src.trashbag = null
		else if(src.bucket)
			src.bucket.set_loc(user.loc)
			user.put_in_hand_or_drop(src.bucket)
			boutput(user, "<span class='notice'>You remove \the [src.bucket] from \the [src]</span>")
			src.bucket = null
		else
			boutput(user, "<span class='alert'>\The [src] has neither trashbag nor bucket.</span>")

	afterattack(atom/target, mob/user, reach, params)
		if(!isturf(user.loc))
			return
		if(ismob(target))
			special.pixelaction(target, params, user, reach) // a hack to let people disarm when clicking at close range
		else if(istype(target, /obj/storage) && src.trashbag)
			var/obj/storage/storage = target
			for(var/obj/item/I in src.trashbag)
				I.set_loc(storage)
			src.trashbag.calc_w_class(null)
			boutput(user, "<span class='notice'>You empty \the [src] into \the [target].</span>")
			src.tooltip_rebuild = 1
			return
		else if(istype(target, /obj/machinery/disposal))
			var/obj/machinery/disposal/disposal = target
			if(src.trashbag)
				for(var/obj/item/I in src.trashbag)
					I.set_loc(disposal)
				src.trashbag.calc_w_class(null)
				boutput(user, "<span class='notice'>You empty \the [src] into \the [target].</span>")
				src.tooltip_rebuild = 1
				disposal.update()
				return
		else if(istype(target, /obj/submachine/chef_sink))
			if(src.bucket.reagents.total_volume > 0)
				boutput(user, "<span class='notice'>You empty \the [src] into \the [target].</span>")
				src.bucket.reagents.clear_reagents()
				src.tooltip_rebuild = 1
			else
				boutput(user, "<span class='notice'>[src]'s bucket is empty.</span>")
			return
		else if(istype(target, /obj/mopbucket) && src.bucket)
			if(src.bucket.reagents.total_volume > 0)
				boutput(user, "<span class='notice'>You empty \the [src] into \the [target].</span>")
				src.bucket.transfer_all_reagents(target, user)
				src.tooltip_rebuild = 1
			else
				boutput(user, "<span class='notice'>[src]'s bucket is empty.</span>")
			return
		if(ON_COOLDOWN(src, "suck", 0.3 SECONDS))
			return
		var/turf/T = get_turf(target)
		if(isnull(T)) // fluids getting disposed or something????
			return
		new/obj/effect/suck(T, get_dir(T, user))
		if(src.suck(T, user))
			playsound(T, 'sound/effects/suck.ogg', 20, TRUE, 0, 1.5)
		else
			playsound(T, 'sound/effects/brrp.ogg', 20, TRUE, 0, 0.8)

	proc/suck(turf/T, mob/user)
		. = TRUE
		var/success = FALSE
		if(T.active_airborne_liquid && T.active_airborne_liquid.group)
			if(isnull(src.bucket))
				boutput(user, "<span class='alert'>\The [src] tries to suck up \the [T.active_airborne_liquid] but has no bucket!</span>")
				. = FALSE
			else if(src.bucket.reagents.is_full())
				boutput(user, "<span class='alert'>\The [src] tries to suck up \the [T.active_airborne_liquid] but its bucket is full!</span>")
				. = FALSE
			else
				var/obj/fluid/airborne/F = T.active_airborne_liquid
				F.group.reagents.skip_next_update = 1
				F.group.update_amt_per_tile()
				var/amt = min(F.group.amt_per_tile, src.bucket.reagents.maximum_volume - src.bucket.reagents.total_volume)
				F.group.drain(F, amt / max(1, F.group.amt_per_tile), src.bucket)
				if(src.bucket.reagents.is_full())
					boutput(user, "<span class='notice'>[src]'s [src.bucket] is now full.</span>")
				success = TRUE

		var/obj/reagent_dispensers/cleanable/ants/ants = locate(/obj/reagent_dispensers/cleanable/ants) in T
		if(ants)
			if(isnull(src.bucket))
				boutput(user, "<span class='alert'>\The [src] tries to suck up the ants but has no bucket!</span>")
				. = FALSE
			else if(src.bucket.reagents.is_full())
				boutput(user, "<span class='alert'>\The [src] tries to suck up the ants but its bucket is full!</span>")
				. = FALSE
			else
				qdel(ants)
				src.bucket.reagents.add_reagent("ants", 5)
				success = TRUE

		var/list/obj/item/items_to_suck = list()
		for(var/obj/item/I in T)
			if((I.w_class <= W_CLASS_TINY || istype(I, /obj/item/raw_material/shard)) && !I.anchored)
				items_to_suck += I
		if(length(items_to_suck))
			var/item_desc = length(items_to_suck) > 1 ? "some items" : "\the [items_to_suck[1]]"
			if(isnull(src.trashbag))
				boutput(user, "<span class='alert'>\The [src] tries to suck up [item_desc] but has no trashbag!</span>")
				. = FALSE
			else if(src.trashbag.current_stuff >= src.trashbag.max_stuff)
				boutput(user, "<span class='alert'>\The [src] tries to suck up [item_desc] but its [src.trashbag] is full!</span>")
				. = FALSE
			else
				for(var/obj/item/I as anything in items_to_suck)
					if(!I.anchored)
						I.set_loc(get_turf(user))
				success = TRUE
				SPAWN(0.5 SECONDS)
					for(var/obj/item/I as anything in items_to_suck) // yes, this can go over capacity of the bag, that's intended
						if(!I.anchored)
							I.set_loc(src.trashbag)
					src.trashbag.calc_w_class(null)
					if(src.trashbag.current_stuff >= src.trashbag.max_stuff)
						boutput(user, "<span class='notice'>[src]'s [src.trashbag] is now full.</span>")

		src.tooltip_rebuild = 1
		. |= success

	attackby(obj/item/W, mob/user, params, is_special=0)
		if(istype(W, /obj/item/clothing/under/trash_bag))
			if(isnull(src.trashbag))
				boutput(user, "<span class='notice'>You insert \the [W] into \the [src].")
				src.trashbag = W
				src.trashbag.set_loc(src)
			else
				boutput(user, "<span class='notice'>You swap the trash bags.")
				var/obj/item/old_trashbag = src.trashbag
				src.trashbag = W
				src.trashbag.set_loc(src)
				old_trashbag.set_loc(user.loc)
				user.put_in_hand_or_drop(old_trashbag)
			user.u_equip(W)
			W.dropped(user)
			src.tooltip_rebuild = 1
		else if(istype(W, /obj/item/reagent_containers/glass/bucket))
			if(isnull(src.bucket))
				boutput(user, "<span class='notice'>You insert \the [W] into \the [src].")
				src.bucket = W
				src.bucket.set_loc(src)
			else
				boutput(user, "<span class='notice'>You swap the buckets.")
				var/obj/item/old_bucket = src.bucket
				src.bucket = W
				src.bucket.set_loc(src)
				old_bucket.set_loc(user.loc)
				user.put_in_hand_or_drop(old_bucket)
			user.u_equip(W)
			W.dropped(user)
			src.tooltip_rebuild = 1
		else
			. = ..()

/obj/item/handheld_vacuum/overcharged
	name = "overcharged handheld vacuum"
	mats = list("neutronium"=3, "MET-1"=10)
	color = list(0,0,1, 0,1,0, 1,0,0)
	New()
		..()
		var/datum/item_special/suck/suck = src.special
		suck.suck_mobs = TRUE
		suck.range = 10
		suck.suck_in_range = 3
		suck.throw_range = 10
		suck.throw_speed = 1
		suck.moveDelayDuration = 5
		suck.moveDelay = 4

/datum/item_special/suck
	cooldown = 30
	staminaCost = 10
	moveDelay = 8
	moveDelayDuration = 10
	var/range = 3
	var/suck_in_range = 1
	var/throw_range = 2
	var/throw_speed = 0.3
	var/suck_mobs = FALSE

	image = "suck"
	name = "Suck"
	desc = "Suck stuff towards you in a 3 tile range."

	pixelaction(atom/target, params, mob/user, reach)
		if(!isturf(target.loc) && !isturf(target)) return
		if(!usable(user)) return
		if(!isturf(user.loc)) return
		var/turf/target_turf = get_turf(target)
		var/turf/master_turf = get_turf(master)
		if(params["left"] && master && (BOUNDS_DIST(master_turf, target_turf) > 0 || ismob(target) && target != user))
			if(ON_COOLDOWN(master, "suck", src.cooldown)) return
			preUse(user)
			var/direction = get_dir_pixel(user, target, params)

			var/list/turf_list = list()
			var/turf/last = get_turf(master)
			var/hit_target = FALSE
			for(var/i = 1 to src.range)
				if(last == target)
					hit_target = TRUE
				var/turf/current
				if(hit_target)
					current = get_step(last, direction)
				else
					current = get_step_towards(last, target)
				turf_list += current
				last = current

			last = get_turf(master)
			var/sucking_in = src.suck_in_range
			for(var/turf/T in turf_list)
				if(T.density)
					break
				if(sucking_in && istype(master, /obj/item/handheld_vacuum))
					sucking_in--
					var/obj/item/handheld_vacuum/vacuum = master
					vacuum.suck(T, user)
				var/end_now
				for(var/atom/movable/A in T)
					if(A.density && !istype(A, /obj/table))
						end_now = TRUE
					if(!A.anchored)
						if(!ismob(A) || src.suck_mobs)
							A.throw_at(T == turf_list[1] ? get_turf(master) : turf_list[1], src.throw_range, src.throw_speed)
							if(ismob(A))
								var/mob/M = A
								M.changeStatus("weakened", 0.9 SECONDS)
								M.force_laydown_standup()
								boutput(M, "<span class='alert'>You are pulled by the force of [user]'s [master].</span>")
						else
							var/mob/M = A
							if(!issilicon(M) && M.equipped() && prob(25))
								var/obj/item/I = M.equipped()
								if(!I.cant_drop)
									I.set_loc(M.loc)
									M.u_equip(I)
									I.dropped(user)
									boutput(M, "<span class='alert'>Your [I] is pulled from your hands by the force of [user]'s [master].</span>")
				new/obj/effect/suck(T, get_dir(T, last))
				last = T
				if(end_now)
					break

			afterUse(user)
			playsound(master, 'sound/effects/suck.ogg', 40, TRUE, 0, 0.5)

/obj/effect/suck
	anchored = 2
	mouse_opacity = FALSE
	plane = PLANE_NOSHADOW_BELOW
	icon = 'icons/effects/effects.dmi'
	icon_state = "push"

	New(atom/loc, dir)
		..()
		src.dir = dir
		src.alpha = 0
		animate(src, alpha=255, time=0.21 SECONDS, easing=SINE_EASING)
		animate(alpha=0, time=0.21 SECONDS, easing=SINE_EASING)
		SPAWN(0.5 SECONDS)
			qdel(src)
