//////////////////////////
// Light revealed wraith trap
//////////////////////////
/obj/machinery/wraith/runetrap
	name = "Rune trap"
	desc = "A strange ominous circle. You should likely tip-toe around this one."
	icon = 'icons/obj/wraith_objects.dmi'
	icon_state = "rune_trap"
	density = 0
	anchored = 1
	var/visible = FALSE
	var/armed = FALSE
	var/mob/living/intangible/wraith/wraith_trickster/master = null

	New(var/turf/T, var/mob/living/intangible/wraith/wraith_trickster/W = null)
		..()
		master = W
		SPAWN(5 SECONDS)
			var/turf/local_turf = get_turf(src)
			if (local_turf.RL_GetBrightness() < 0.3)
				APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_CLOAK)
				animate(src, alpha=120, time = 1 SECONDS)
			src.armed = TRUE

	process()
		..()
		if (!src.armed)	//Wait until we are armed.
			return
		var/turf/local_turf = get_turf(src)
		if (local_turf.RL_GetBrightness() < 0.3 && src.visible)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_CLOAK)
			src.visible = FALSE
			animate(src, alpha=120, time = 1 SECONDS)
		else if (local_turf.RL_GetBrightness() >= 0.2 && !src.visible)
			REMOVE_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src)
			src.visible = TRUE
			animate(src, alpha=255, time = 1 SECONDS)
			src.visible_message("<span class='alert>[src] is revealed!")

	attackby(obj/item/P, mob/living/user)
		playsound(src, 'sound/impact_sounds/Crystal_Shatter_1.ogg', 80)
		src.visible_message("<span class='notice'>The trap is destroyed!</span>")
		qdel(src)

	disposing()
		if (master != null)
			master.traps_laid--
		. = ..()

	/// attempts to detonate a runetrap, checks if the trap is armed and if the crosser is a valid target
	proc/try_trigger(atom/movable/AM)
		if(!armed) return
		if(!isliving(AM)) return
		if(istype(AM, /mob/living/critter/wraith/trickster_puppet)) return
		return TRUE


/obj/machinery/wraith/runetrap/madness
	var/amount_to_inject = 8

	Crossed(atom/movable/AM)
		..()
		if(!try_trigger(AM)) return
		var/mob/M = AM
		if(!checkRun(M)) return
		if(!M.reagents) return
		if (M.reagents.total_volume + src.amount_to_inject >= M.reagents.maximum_volume)
			M.reagents.remove_any(M.reagents.total_volume + amount_to_inject - M.reagents.maximum_volume)
		M.reagents.add_reagent("madness_toxin", src.amount_to_inject)
		src.visible_message("<span class='alert>[M] steps on [src] and triggers it!</span>")
		boutput(M, "<span class='alert'>Visions of murder and blood fill your mind. Rage builds up inside of you!</span>")
		playsound(src, 'sound/voice/wraith/wraithraise3.ogg', 80)
		elecflash(src, 1, 1)
		qdel(src)

/obj/machinery/wraith/runetrap/sleepyness
	var/amount_to_inject = 15

	Crossed(atom/movable/AM)
		..()
		if(!try_trigger(AM)) return
		var/mob/M = AM
		if(!checkRun(M)) return
		M.changeStatus("drowsy", 30 SECONDS)
		if (M.reagents.total_volume + src.amount_to_inject >= M.reagents.maximum_volume)
			M.reagents.remove_any(M.reagents.total_volume + amount_to_inject - M.reagents.maximum_volume)
		M.reagents.add_reagent("haloperidol", src.amount_to_inject)
		src.visible_message("<span class='alert>[M] steps on [src] and triggers it!</span>")
		boutput(M, "<span class='notice'>You start to feel really sleepy!</span>")
		playsound(src, 'sound/voice/wraith/wraithraise3.ogg', 80)
		elecflash(src, 1, 1)
		qdel(src)

/obj/machinery/wraith/runetrap/stunning
	Crossed(atom/movable/AM)
		..()
		if(!try_trigger(AM)) return
		var/mob/M = AM
		if(!checkRun(M)) return
		flashpowder_reaction(get_turf(src), 40)
		playsound(src, 'sound/weapons/flashbang.ogg', 25, 1)
		M.changeStatus("stunned", 4 SECONDS)
		src.visible_message("<span class='alert>[M] steps on [src] and triggers it! A bright light flashes</span>")
		playsound(src, 'sound/voice/wraith/wraithraise3.ogg', 80)
		elecflash(src, 1, 1)
		qdel(src)

/obj/machinery/wraith/runetrap/emp
	Crossed(atom/movable/AM)
		..()
		var/area/AR = get_area(src)
		if(AR.sanctuary) return
		if(!try_trigger(AM)) return
		var/mob/M = AM
		if(!checkRun(M)) return
		var/turf/T = get_turf(M)
		for (var/atom/A as anything in T.contents)
			A.emp_act()
		playsound(src, 'sound/effects/electric_shock_short.ogg', 30, 1)
		src.visible_message("<span class='alert>[M] steps on [src] and triggers it! Your hair stands on end!</span>")
		playsound(src, 'sound/voice/wraith/wraithraise3.ogg', 80)
		elecflash(src, 1, 1)
		qdel(src)

/obj/machinery/wraith/runetrap/terror
	Crossed(atom/movable/AM)
		..()
		if(!try_trigger(AM)) return
		var/mob/M = AM
		if(!checkRun(M)) return
		for (var/mob/living/L in range(4, src))
			if(istype(L, /mob/living/critter/wraith/trickster_puppet)) continue
			L.setStatus("terror", 45 SECONDS)

		src.visible_message("<span class='alert>[M] steps on [src] and triggers it! Your mind fills with terrible visions!</span>")
		playsound(src, 'sound/voice/wraith/wraithraise3.ogg', 80)
		elecflash(src, 1, 1)
		qdel(src)

/obj/machinery/wraith/runetrap/fire
	Crossed(atom/movable/AM)
		..()
		if(!try_trigger(AM)) return
		var/mob/M = AM
		if(!checkRun(M)) return
		fireflash(M, 1, TRUE)
		playsound(src, 'sound/effects/mag_fireballlaunch.ogg', 50, 0)
		src.visible_message("<span class='alert>[M] steps on [src] and triggers it! A flame engulfs them immediatly!</span>")
		playsound(src, 'sound/voice/wraith/wraithraise3.ogg', 80)
		elecflash(src, 1, 1)
		qdel(src)

/obj/machinery/wraith/runetrap/teleport
	var/range = 5

	Crossed(atom/movable/AM)
		..()
		if(!try_trigger(AM)) return
		var/mob/M = AM
		if(!checkRun(M)) return
		if (isrestrictedz(M.z))
			src.visible_message("<span class='alert>[M] steps on [src] and triggers it! It missfires, sputters and dies!</span>")
			elecflash(src, 2, 1)
			qdel(src)
			return 1
		var/turf/src_turf = get_turf(src)
		var/list/turfs = block(locate(max(src_turf.x - range, 0), max(src_turf.y - range, 0), src_turf.z), locate(min(src_turf.x + range, world.maxx), min(src_turf.y + range, world.maxy), src_turf.z))
		var/list/valid_turfs = list()
		for (var/turf/T as anything in turfs)
			if (T.density) continue
			if (istype(T, /turf/space)) continue
			valid_turfs += T
		if (!length(valid_turfs))
			return //guess we're already in the middle of fricken nowhere!
		src.visible_message("<span class='alert>[M] steps on [src] and triggers it! A flame engulfs them immediatly!</span>")
		playsound(src, 'sound/voice/wraith/wraithraise3.ogg', 80)
		boutput(M, text("<span class='alert'>You blink, and suddenly you're somewhere else!</span>"))
		playsound(M.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)
		M.set_loc(pick(valid_turfs))
		elecflash(src, 1, 1)
		qdel(src)

/obj/machinery/wraith/runetrap/explosive
	Crossed(atom/movable/AM)
		..()
		if(!try_trigger(AM)) return
		var/mob/M = AM
		if(!checkRun(M)) return
		src.visible_message("<span class='alert>[M] steps on [src] and triggers it! You hear a buzzing sound!</span>")
		playsound(src, 'sound/voice/wraith/wraithraise3.ogg', 80)
		explosion(src, src, -1, 1, 2, 4)
		elecflash(src, 1, 1)
		qdel(src)

/obj/machinery/wraith/runetrap/slipping
	Crossed(atom/movable/AM)
		..()
		if(!try_trigger(AM)) return
		var/mob/M = AM
		if(!checkRun(M)) return
		src.visible_message("<span class='alert>[M] steps on [src] and triggers it! You can hear a slippery sound!</span>")
		M.remove_pulling()
		M.changeStatus("weakened", 3 SECONDS)
		boutput(M, "<span class='notice'>You suddenly slip!</span>")
		playsound(M, 'sound/misc/slip.ogg', 50, 1, -3)
		var/atom/target = get_edge_target_turf(M, M.dir)
		M.throw_at(target, 12, 1, throw_type = THROW_SLIP)
		playsound(src, 'sound/voice/wraith/wraithraise3.ogg', 80)
		elecflash(src, 1, 1)

/proc/checkRun(var/mob/M)	//If we are above walking speed, this triggers
	if(!M) return
	var/slip_delay = BASE_SPEED_SUSTAINED + WALK_DELAY_ADD
	var/movement_delay_real = max(M.movement_delay(get_step(M,M.move_dir), 0),world.tick_lag)
	var/movedelay = clamp(world.time - M.next_move, movement_delay_real, world.time - M.last_pulled_time)
	if (movedelay < slip_delay)
		return TRUE
