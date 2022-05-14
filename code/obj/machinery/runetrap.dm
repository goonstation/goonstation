//////////////////////////
// Light revealed wraith trap
//////////////////////////
// Todo, play a sound on trap trigger
/obj/machinery/wraith/runetrap
	name = "Rune trap"
	desc = "A strange ominous circle. You should likely tip-toe around this one."
	icon = 'icons/obj/furniture/table.dmi'
	density = 0
	anchored = 1
	var/visible = FALSE
	var/armed = FALSE

	New()
		..()
		SPAWN(5 SECONDS)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_CLOAK)
			src.armed = TRUE
			src.visible = FALSE
			animate(src, alpha=120, time = 1 SECONDS)

	process()
		..()
		if (!src.armed)	//Wait until we are armed.
			return 1
		var/found_light = FALSE
		for (var/obj/machinery/light/L in view(3, src))
			if(L.on && !istype(L, /obj/machinery/light/emergency) && !istype(L, /obj/machinery/light/emergencyflashing))	//We cant break emergency lights, so ignore them
				found_light = TRUE
				if(!src.visible)
					REMOVE_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src)
					src.visible = TRUE
					animate(src, alpha=255, time = 1 SECONDS)
					src.visible_message("<span class='alert>[src] is revealed!")
		if(!found_light)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_CLOAK)
			src.visible = FALSE
			animate(src, alpha=120, time = 1 SECONDS)

	attackby(obj/item/P, mob/living/user)
		//Todo, play a sound here
		src.visible_message("<span class='notice'>The trap is destroyed!</span>")
		qdel(src)

/obj/machinery/wraith/runetrap/madness

	var/amount_to_inject = 8

	Crossed(atom/movable/A)
		..()
		if(!src.armed)
			return 1
		if(ismob(A))
			var/mob/M = A
			if(checkRun(M))
				if(M.reagents)
					if (M.reagents.total_volume + src.amount_to_inject >= M.reagents.maximum_volume)
						M.reagents.remove_any(M.reagents.total_volume + amount_to_inject - M.reagents.maximum_volume)
					M.reagents.add_reagent("madness_toxin", src.amount_to_inject)
					src.visible_message("[M] steps on [src] and triggers it!")
					elecflash(src, 1, 1)
					qdel(src)


/proc/checkRun(var/mob/M)	//If we are above walking speed, this triggers
	if(M != null)
		var/slip_delay = BASE_SPEED_SUSTAINED + WALK_DELAY_ADD
		var/movement_delay_real = max(M.movement_delay(get_step(M,M.move_dir), 0),world.tick_lag)
		var/movedelay = clamp(world.time - M.next_move, movement_delay_real, world.time - M.last_pulled_time)

		if (movedelay < slip_delay)
			return TRUE
		else
			return FALSE
