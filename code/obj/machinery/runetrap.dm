//////////////////////////
// Light revealed wraith trap
//////////////////////////
/obj/machinery/wraith/runetrap
	name = "Rune trap"
	desc = "A strange ominous circle. You should likely tip-toe around this one."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rune_trap"
	density = 0
	anchored = 1
	var/visible = FALSE
	var/armed = FALSE
	var/mob/wraith/wraith_trickster/master = null

	New(var/turf/T, var/mob/wraith/wraith_trickster/W = null)
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
			return 1
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
		playsound(src, "sound/impact_sounds/Crystal_Shatter_1.ogg", 80)
		src.visible_message("<span class='notice'>The trap is destroyed!</span>")
		qdel(src)

	disposing()
		. = ..()
		if (master != null)
			master.traps_laid--

/obj/machinery/wraith/runetrap/madness
	var/amount_to_inject = 8

	Crossed(atom/movable/A)
		..()
		if(!src.armed)
			return 1
		if(ismob(A) && !istype(A, /mob/living/critter/wraith/trickster_puppet) && !istype(A, /mob/wraith))
			var/mob/M = A
			if(checkRun(M))
				if(M.reagents)
					if (M.reagents.total_volume + src.amount_to_inject >= M.reagents.maximum_volume)
						M.reagents.remove_any(M.reagents.total_volume + amount_to_inject - M.reagents.maximum_volume)
					M.reagents.add_reagent("madness_toxin", src.amount_to_inject)
					src.visible_message("<span class='alert>[M] steps on [src] and triggers it!</span>")
					boutput(M, "<span class='alert'>Visions of murder and blood fill your mind. Rage builds up inside of you!</span>")
					playsound(src, "sound/voice/wraith/wraithraise3.ogg", 80)
					elecflash(src, 1, 1)
					qdel(src)

/obj/machinery/wraith/runetrap/sleepyness
	var/amount_to_inject = 15

	Crossed(atom/movable/A)
		..()
		if(!src.armed)
			return 1
		if(ismob(A) && !istype(A, /mob/living/critter/wraith/trickster_puppet) && !istype(A, /mob/wraith))
			var/mob/M = A
			if(checkRun(M))
				M.changeStatus("drowsy", 30 SECONDS)
				if(M.reagents)
					if (M.reagents.total_volume + src.amount_to_inject >= M.reagents.maximum_volume)
						M.reagents.remove_any(M.reagents.total_volume + amount_to_inject - M.reagents.maximum_volume)
					M.reagents.add_reagent("haloperidol", src.amount_to_inject)
					src.visible_message("<span class='alert>[M] steps on [src] and triggers it!</span>")
					boutput(M, "<span class='notice'>You start to feel really sleepy!</span>")
					playsound(src, "sound/voice/wraith/wraithraise3.ogg", 80)
					elecflash(src, 1, 1)
					qdel(src)

/obj/machinery/wraith/runetrap/stunning
	Crossed(atom/movable/A)
		..()
		if(!src.armed)
			return 1
		if(ismob(A) && !istype(A, /mob/living/critter/wraith/trickster_puppet) && !istype(A, /mob/wraith))
			var/mob/M = A
			if(checkRun(M))
				flashpowder_reaction(get_turf(src), 40)
				playsound(src, "sound/weapons/flashbang.ogg", 25, 1)
				M.changeStatus("stunned", 4 SECONDS)
				src.visible_message("<span class='alert>[M] steps on [src] and triggers it! A bright light flashes</span>")
				playsound(src, "sound/voice/wraith/wraithraise3.ogg", 80)
				elecflash(src, 1, 1)
				qdel(src)

/obj/machinery/wraith/runetrap/emp
	Crossed(atom/movable/A)
		..()
		if(!src.armed)
			return 1
		if(ismob(A) && !istype(A, /mob/living/critter/wraith/trickster_puppet) && !istype(A, /mob/wraith))
			var/mob/M = A
			if(checkRun(M))
				var/turf/T = get_turf(M)
				for (var/atom/O in T.contents)
					var/area/t = get_area(O)
					if(t?.sanctuary) continue
					O.emp_act()
				playsound(src, "sound/effects/electric_shock_short.ogg", 30, 1)
				src.visible_message("<span class='alert>[M] steps on [src] and triggers it! Your hair stands on end!</span>")
				playsound(src, "sound/voice/wraith/wraithraise3.ogg", 80)
				elecflash(src, 1, 1)
				qdel(src)

/obj/machinery/wraith/runetrap/terror
	Crossed(atom/movable/A)
		..()
		if(!src.armed)
			return 1
		if(ismob(A) && !istype(A, /mob/living/critter/wraith/trickster_puppet) && !istype(A, /mob/wraith))
			var/mob/M = A
			if(checkRun(M))
				for (var/mob/H in range(4, src))
					H.setStatus("terror", 45 SECONDS)

				src.visible_message("<span class='alert>[M] steps on [src] and triggers it! Your mind fills with terrible visions!</span>")
				playsound(src, "sound/voice/wraith/wraithraise3.ogg", 80)
				elecflash(src, 1, 1)
				qdel(src)

/obj/machinery/wraith/runetrap/fire
	Crossed(atom/movable/A)
		..()
		if(!src.armed)
			return 1
		if(ismob(A) && !istype(A, /mob/living/critter/wraith/trickster_puppet) && !istype(A, /mob/wraith))
			var/mob/M = A
			if(checkRun(M))
				fireflash(M, 1, TRUE)
				playsound(src, "sound/effects/mag_fireballlaunch.ogg", 50, 0)
				src.visible_message("<span class='alert>[M] steps on [src] and triggers it! A flame engulfs them immediatly!</span>")
				playsound(src, "sound/voice/wraith/wraithraise3.ogg", 80)
				elecflash(src, 1, 1)
				qdel(src)

/obj/machinery/wraith/runetrap/teleport
	Crossed(atom/movable/A)
		..()
		if(!src.armed)
			return 1
		if(ismob(A) && !istype(A, /mob/living/critter/wraith/trickster_puppet) && !istype(A, /mob/wraith))
			var/mob/M = A
			if(checkRun(M))
				var/telerange = 5
				var/list/randomturfs = new/list()
				if (isrestrictedz(M.z))
					src.visible_message("<span class='alert>[M] steps on [src] and triggers it! It missfires, sputters and dies!</span>")
					elecflash(src, 2, 1)
					qdel(src)
					return 1
				for(var/turf/T in orange(M, telerange))
					if(istype(T, /turf/space) || T.density) continue
					randomturfs.Add(T)
				if (length(randomturfs) <= 0)
					return 1
				src.visible_message("<span class='alert>[M] steps on [src] and triggers it! A flame engulfs them immediatly!</span>")
				playsound(src, "sound/voice/wraith/wraithraise3.ogg", 80)
				boutput(M, text("<span class='alert'>You blink, and suddenly you're somewhere else!</span>"))
				playsound(M.loc, "sound/effects/mag_warp.ogg", 25, 1, -1)
				M.set_loc(pick(randomturfs))
				elecflash(src, 1, 1)
				qdel(src)

/obj/machinery/wraith/runetrap/explosive
	Crossed(atom/movable/A)
		..()
		if(!src.armed)
			return 1
		if(ismob(A) && !istype(A, /mob/living/critter/wraith/trickster_puppet) && !istype(A, /mob/wraith))
			var/mob/M = A
			if(checkRun(M))
				src.visible_message("<span class='alert>[M] steps on [src] and triggers it! You hear a buzzing sound!</span>")
				playsound(src, 'sound/voice/wraith/wraithraise3.ogg', 80)
				explosion(src, src, -1, 1, 2, 4)
				elecflash(src, 1, 1)
				qdel(src)

/obj/machinery/wraith/runetrap/slipping
	Crossed(atom/movable/A)
		..()
		if(!src.armed)
			return 1
		if(ismob(A) && !istype(A, /mob/living/critter/wraith/trickster_puppet) && !istype(A, /mob/wraith))
			var/mob/M = A
			if(checkRun(M))
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
	if(M != null)
		var/slip_delay = BASE_SPEED_SUSTAINED + WALK_DELAY_ADD
		var/movement_delay_real = max(M.movement_delay(get_step(M,M.move_dir), 0),world.tick_lag)
		var/movedelay = clamp(TIME - M.next_move, movement_delay_real, TIME - M.last_pulled_time)

		if (movedelay < slip_delay)
			return TRUE
		else
			return FALSE
