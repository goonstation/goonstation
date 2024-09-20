//////////////////////////
// Light revealed wraith trap
//////////////////////////
/obj/machinery/wraith/runetrap
	name = "rune trap"
	desc = "A strange ominous circle. You should likely tip-toe around this one."
	icon = 'icons/obj/wraith_objects.dmi'
	icon_state = "rune_trap"
	density = 0
	anchored = ANCHORED
	var/visible = FALSE
	var/armed = FALSE
	var/mob/living/intangible/wraith/wraith_trickster/master = null

	New(turf/T, mob/living/intangible/wraith/wraith_trickster/W = null, mob/placing_mob)
		..()
		master = W
		SPAWN(5 SECONDS)
			if (!QDELETED(src))
				var/turf/local_turf = get_turf(src)
				if (local_turf.RL_GetBrightness() < 0.3)
					APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_CLOAK)
					animate(src, alpha=120, time = 1 SECONDS)
				src.armed = TRUE
				boutput(placing_mob, SPAN_NOTICE("The rune trap you placed to the [dir2text(get_dir(placing_mob, src.loc))] has armed."))

	process()
		..()
		if (!src.armed)	//Wait until we are armed.
			return
		var/turf/local_turf = get_turf(src)
		if (local_turf.RL_GetBrightness() < 0.3 && src.visible)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_CLOAK)
			src.visible = FALSE
			animate(src, alpha = 120, time = 1 SECONDS)
		else if (local_turf.RL_GetBrightness() >= 0.2 && !src.visible)
			REMOVE_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src)
			src.visible = TRUE
			animate(src, alpha = 255, time = 1 SECONDS)
			src.visible_message(SPAN_ALERT("[src] is revealed!"))

	attackby(obj/item/P, mob/living/user)
		playsound(src, 'sound/impact_sounds/Crystal_Shatter_1.ogg', 80)
		src.visible_message(SPAN_ALERT("[src] is destroyed!"))
		qdel(src)

	disposing()
		if (master != null)
			master.traps_laid--
		. = ..()

	Crossed(atom/movable/AM)
		..()
		if (!try_trigger(AM))
			return
		AM.visible_message(
			SPAN_ALERT("[AM] steps on [src] and triggers it!"),
			SPAN_ALERT("You step on [src] and trigger it!")
		)
		on_trigger(AM)
		playsound(src, 'sound/voice/wraith/wraithraise3.ogg', 80)
		elecflash(src, 1, 1)
		qdel(src)

	/// attempts to detonate a runetrap, checks if the trap is armed and if the crosser is a valid target
	proc/try_trigger(atom/movable/AM)
		if(!armed)
			return
		if(!isliving(AM))
			return
		if(istype(AM, /mob/living/critter/wraith/trickster_puppet))
			return
		if(isintangible(AM))
			return
		if(!checkRun(AM))
			return
		if(isghostdrone(AM))
			return
		if(isghostcritter(AM))
			return
		return TRUE

	proc/on_trigger(mob/living/M)
		return


/obj/machinery/wraith/runetrap/madness
	var/amount_to_inject = 8

	on_trigger(mob/living/M)
		if (!M.reagents)
			boutput(M, SPAN_ALERT("...but you don't feel any different. Huh."))
			return
		if (M.reagents.total_volume + src.amount_to_inject >= M.reagents.maximum_volume)
			M.reagents.remove_any(M.reagents.total_volume + amount_to_inject - M.reagents.maximum_volume)
		M.reagents.add_reagent("madness_toxin", src.amount_to_inject)
		boutput(M, SPAN_ALERT("Visions of murder and blood fill your mind. Rage builds up inside of you!"))

/obj/machinery/wraith/runetrap/sleepyness
	var/amount_to_inject = 15

	on_trigger(mob/living/M)
		if (!M.reagents)
			boutput(M, SPAN_ALERT("...but you don't feel any different. Huh."))
			return
		M.changeStatus("drowsy", 30 SECONDS)
		if (M.reagents.total_volume + src.amount_to_inject >= M.reagents.maximum_volume)
			M.reagents.remove_any(M.reagents.total_volume + amount_to_inject - M.reagents.maximum_volume)
		M.reagents.add_reagent("haloperidol", src.amount_to_inject)
		boutput(M, SPAN_NOTICE("You start to feel really sleepy..."))
		playsound(src, 'sound/voice/wraith/wraithraise3.ogg', 80)
		elecflash(src, 1, 1)
		qdel(src)

/obj/machinery/wraith/runetrap/stunning
	on_trigger(mob/living/M)
		flashpowder_reaction(get_turf(src), 40)
		playsound(src, 'sound/weapons/flashbang.ogg', 25, TRUE)
		M.changeStatus("stunned", 4 SECONDS)

/obj/machinery/wraith/runetrap/emp
	on_trigger(mob/living/M)
		var/turf/T = get_turf(M)
		for (var/atom/A as anything in T.contents)
			A.emp_act()
		playsound(src, 'sound/effects/electric_shock_short.ogg', 30, TRUE)

/obj/machinery/wraith/runetrap/terror
	on_trigger(mob/living/M)
		..()
		for (var/mob/living/L in range(4, src))
			if(istype(L, /mob/living/critter/wraith/trickster_puppet))
				continue
			L.setStatus("terror", 45 SECONDS)
			boutput(L, SPAN_ALERT("Your mind fills with terrible visions!"))

/obj/machinery/wraith/runetrap/fire
	on_trigger(mob/living/M)
		fireflash(M, 1, checkLos = FALSE, chemfire = CHEM_FIRE_RED)
		playsound(src, 'sound/effects/mag_fireballlaunch.ogg', 50, FALSE)

/obj/machinery/wraith/runetrap/teleport
	var/range = 5

	on_trigger(mob/living/M)
		if (isrestrictedz(M.z))
			src.visible_message(SPAN_ALERT("...but it sputters and dies! Guess it doesn't work here!"))
			elecflash(src, 2, 1)
			return
		var/turf/src_turf = get_turf(src)
		var/list/turfs = block(locate(max(src_turf.x - range, 0), max(src_turf.y - range, 0), src_turf.z), locate(min(src_turf.x + range, world.maxx), min(src_turf.y + range, world.maxy), src_turf.z))
		var/list/valid_turfs = list()
		for (var/turf/T as anything in turfs)
			if (T.density)
				continue
			if (istype(T, /turf/space))
				valid_turfs += T
		if (!length(valid_turfs))
			src.visible_message(SPAN_ALERT("...but nothing happens! Neat."))
			return //guess we're already in the middle of fricken nowhere!
		M.visible_message(
			SPAN_ALERT("[M] vanishes in a flash of smoke!"),
			SPAN_ALERT("You blink, and suddenly you're somewhere else!")
		)
		playsound(M.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)
		M.set_loc(pick(valid_turfs))

/obj/machinery/wraith/runetrap/explosive
	on_trigger(mob/living/M)
		explosion(src, src, -1, 1, 2, 4)

/obj/machinery/wraith/runetrap/slipping
	on_trigger(mob/living/M)
		M.remove_pulling()
		M.changeStatus("knockdown", 3 SECONDS)
		boutput(M, SPAN_ALERT("An ethereal force sends you tumbling!"))
		playsound(M, 'sound/misc/slip.ogg', 50, TRUE, -3)
		var/atom/target = get_edge_target_turf(M, M.dir)
		M.throw_at(target, 12, 1, throw_type = THROW_SLIP)

/proc/checkRun(var/mob/M)	//If we are above walking speed, this triggers
	if(!M) return
	var/slip_delay = BASE_SPEED_SUSTAINED + WALK_DELAY_ADD
	var/movement_delay_real = max(M.movement_delay(get_step(M,M.move_dir), 0),world.tick_lag)
	var/movedelay = clamp(world.time - M.next_move, movement_delay_real, world.time - M.last_pulled_time)
	if (movedelay < slip_delay)
		return TRUE
