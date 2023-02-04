TYPEINFO(/obj/machinery/crusher)
	mats = 20

/obj/machinery/crusher
	name = "Crusher Unit"
	desc = "Breaks things down into metal/glass/waste"
	pass_unstable = TRUE
	density = 1
	icon = 'icons/obj/scrap.dmi'
	icon_state = "Crusher_1"
	layer = MOB_LAYER - 1
	anchored = 1
	is_syndicate = 1
	power_usage = 500
	flags = FLUID_SUBMERGE | UNCRUSHABLE
	event_handler_flags = USE_FLUID_ENTER
	var/osha_prob = 40 //How likely it is anyone touching it is to get dragged in
	var/list/poking_jerks = null //Will be a list if need be

	var/active = 0

	var/last_sfx = 0

/obj/machinery/crusher/Bumped(atom/movable/AM)
	return_if_overlay_or_effect(AM)
	if(AM.flags & UNCRUSHABLE || AM.anchored == 2)
		return

	var/turf/T = get_turf(src)
	if (T.density) // no clipping through walls ty
		return

	if(!(AM.temp_flags & BEING_CRUSHERED))
		actions.start(new /datum/action/bar/crusher(AM), src)

/obj/machinery/crusher/Cross(atom/movable/mover)
	. = ..()
	if(mover.flags & UNCRUSHABLE || mover.anchored == 2)
		. = TRUE

/obj/machinery/crusher/Crossed(atom/movable/AM)
	. = ..()
	return_if_overlay_or_effect(AM)
	if(AM.flags & UNCRUSHABLE || AM.anchored == 2)
		return

	var/turf/T = get_turf(src)
	if (T.density) // no clipping through walls ty
		return

	if(!(AM.temp_flags & BEING_CRUSHERED))
		actions.start(new /datum/action/bar/crusher(AM), src)

/datum/action/bar/crusher
	duration = 12 SECONDS
	interrupt_flags = INTERRUPT_MOVE
	var/atom/movable/target
	var/classic

	New(atom/movable/target, ignore_z = FALSE)
		. = ..()
		var/turf/T = get_turf(target)
		src.target = target
		if (!ignore_z && T)
			src.classic = isrestrictedz(T.z)
		if(!ismob(target))
			duration = rand(0, 20) DECI SECONDS
			src.bar_icon_state = ""
			src.border_icon_state = ""

		if(src.classic)
			duration = 0 SECONDS
	onStart()
		. = ..()
		if (!ON_COOLDOWN(owner, "crusher_sound", 1 SECOND))
			playsound(owner, 'sound/items/mining_drill.ogg', 40, 1,0,0.8)
		target.temp_flags |= BEING_CRUSHERED
		if(!src.classic)
			target.set_loc(owner.loc)
		walk(target, 0)
		target.changeStatus("stunned", 5 SECONDS)


	onUpdate()
		. = ..()
		if(!(BOUNDS_DIST(owner, target) == 0) || QDELETED(target))
			interrupt(INTERRUPT_ALWAYS)
			return
		if (!ON_COOLDOWN(owner, "crusher_sound", rand(0.5, 2.5) SECONDS))
			playsound(owner, 'sound/items/mining_drill.ogg', 40, 1,0,0.8)
		if(!src.classic)
			target.set_loc(owner.loc)

		if(ismob(target))
			var/mob/M = target
			random_brute_damage(M, rand(5, 10), TRUE)
			take_bleeding_damage(M, null, 10, DAMAGE_CRUSH)
			playsound(M, pick('sound/impact_sounds/Flesh_Stab_1.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/impact_sounds/Slimy_Splat_1.ogg','sound/impact_sounds/Flesh_Tear_2.ogg','sound/impact_sounds/Slimy_Hit_3.ogg'), 66)
			if(prob(10) && ishuman(M))
				var/mob/living/carbon/human/H = M
				H.limbs?.sever(pick("l_arm", "r_arm", "l_leg", "r_leg"))
			if(!ON_COOLDOWN(M, "crusher_scream", 2 SECONDS))
				M.emote("scream", FALSE)

	onInterrupt(flag)
		. = ..()
		if(ismob(target) && !QDELETED(target) && (target.temp_flags & BEING_CRUSHERED))
			var/mob/M = target
			random_brute_damage(M, rand(15, 45))
			take_bleeding_damage(M, null, 10, DAMAGE_CRUSH)
			playsound(M, pick('sound/impact_sounds/Flesh_Stab_1.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/impact_sounds/Slimy_Splat_1.ogg','sound/impact_sounds/Flesh_Tear_2.ogg','sound/impact_sounds/Slimy_Hit_3.ogg'), 100)
			M.emote("scream", FALSE)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.limbs?.sever("both_legs")
		target.temp_flags &= ~BEING_CRUSHERED


	onEnd()
		. = ..()
		if(!(BOUNDS_DIST(owner, target) == 0) || QDELETED(target))
			interrupt(INTERRUPT_ALWAYS)
			return

		var/tm_amt = 0
		var/tg_amt = 0
		var/tw_amt = 0
		var/bblood = 0
		var/atom/AM = target

		if(ismob(AM))
			var/mob/M = AM
			M.set_loc(owner.loc)
			for(var/obj/O in M.contents)
				if(isobj(O))
					tm_amt += O.m_amt
					tg_amt += O.g_amt
					tw_amt += O.w_amt
					if(iscarbon(M))
						tw_amt += 5000
						bblood = 2
					else if(issilicon(M))
						tm_amt += 5000
						tg_amt += 1000
				qdel(O)
			logTheThing(LOG_COMBAT, M, "is ground up in a crusher at [log_loc(owner)].")
			M.gib()
		else if(istype(AM, /obj))
			var/obj/B = AM
			tm_amt += B.m_amt
			tg_amt += B.g_amt
			tw_amt += B.w_amt
			for(var/obj/O in AM.contents)
				if(isobj(O))
					tm_amt += O.m_amt
					tg_amt += O.g_amt
					tw_amt += O.w_amt
				qdel(O)
		else
			return

		if (!ON_COOLDOWN(owner, "crusher_sound", 1 SECOND))
			playsound(owner, 'sound/items/mining_drill.ogg', 40, 1,0,0.8)

		var/obj/item/scrap/S = new(get_turf(owner))
		S.blood = bblood
		S.set_components(tm_amt,tg_amt,tw_amt)
		qdel(AM)
	//		step(S,2)
		return


/obj/machinery/crusher/attack_hand(mob/user)
	if(!user || user.stat || BOUNDS_DIST(user, src) > 0 || isintangible(user)) //No unconscious / dead / distant users
		return

	//Daring text showing how BRAVE THIS PERSON IS!!!
	if(new_poker(user)) //Alright, this person is not currently touching the crusher

		user.visible_message("<span class='combat bold'>[user] [pick_string("descriptors.txt", "crusherpoke")] the [src]!</span>")
		if(prob(osha_prob)) //RIP you.
			user.canmove = 0
			user.anchored = 1
			sleep(0.5 SECONDS) //Give it a little time
			if(user) //Gotta make sure they haven't moved since last time
				poking_jerks -= user
				user.visible_message("<span class='combat bold'>...and gets pulled in! SHIT!!</span>")
				user.emote("scream")
				user.set_loc(get_turf(src)) //So it looks like they're actually pulled in
				src.Bumped(user)
				if(user) //Still here somehow?
					user.gib() //Not any more you aren't.
		else //Whew
			//So that we can restore their proper values after
			var/cmn = user.canmove
			var/anc = user.anchored
			//To prevent them moving away.
			user.canmove = 0
			user.anchored = 1
			interact_particle(user,src)
			sleep(0.5 SECONDS)
			if(user) //Still here?
				poking_jerks -= user
				user.visible_message("<span class='combat bold'>[pick_string("descriptors.txt", "crusherbrave")]</span>")
				user.canmove = cmn
				user.anchored = anc
	else //Oh, they are still touching the crusher.
		poking_jerks -= user
		user.visible_message("<span class='combat bold'>[user] jams [his_or_her(user)] entire arm into \the [src] in a shocking display of bravery! They are promptly dragged into it! FUCK!!</span>")
		user.emote("scream")
		user.set_loc(get_turf(src)) //So it looks like they're actually pulled in
		src.Bumped(user)
		if(user) //Still here somehow?
			user.gib() //Not any more you aren't.

/obj/machinery/crusher/proc/new_poker(var/mob/jerk)
	if(!islist(poking_jerks))
		poking_jerks = list(jerk)
	else if(poking_jerks.Find(jerk))
		return 0
	else
		poking_jerks += jerk

	return 1

/obj/machinery/crusher/process()
	..()
	if(status & (NOPOWER|BROKEN))	return

/obj/machinery/crusher/New()
	..()
	var/turf/T = get_turf(src)
	if (T.contents.len > 100) //if it has to check too much stuff, it might lag?
		src.visible_message("<span style='color:red'>\The [src] fails to deploy because of how much stuff there is on the ground! Clean it up!</span>")
		qdel(src)
		return
	var/obj/machinery/crusher/C = locate(/obj/machinery/crusher) in T
	if(C != src)
		src.visible_message("<span style='color:red'>\The [src] fails to deploy because there's already a crusher there! Find someplace else!")
		qdel(src)
		return
	for (var/atom/movable/AM in T) //heh
		src.Crossed(AM)
