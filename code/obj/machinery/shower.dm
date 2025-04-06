//It's like a chem grenade that never ends
//And also makes people cleaner.

/obj/machinery/shower
	name = "shower head"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showerhead"
	desc = "A shower head, for showering."
	anchored = ANCHORED
	flags = OPENCONTAINER
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WIRECUTTERS

	var/on = 0 //Are we currently spraying???
	var/default_reagent = "cleaner" //Some water will also be added.
	var/add_water = 1 // ...unless this is 0
	var/tmp/last_spray = 0

#define SPRAY_DELAY 5 //Delay between sprays, in tenths of a second.
							//Don't set it to 50 or below thanks (reagents need to clear)

	New()
		..()
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "toggle", PROC_REF(mechcomp_toggle))
		src.create_reagents(320)

	///Silly wrapper proc to drop the args
	proc/mechcomp_toggle()
		src.toggle(null)

	was_deconstructed_to_frame(mob/user)
		if (src.on)
			src.toggle(user)

	attack_ai(mob/user as mob)
		src.toggle(user)

	attack_hand(mob/user)
		src.toggle(user)

	proc/toggle(mob/user)
		src.on = !src.on
		if (src.on)
			SubscribeToProcess()
		else
			UnsubscribeProcess()
		if (user)
			boutput(user, "You turn [src.on ? "on" : "off"] \the [src].")

#ifdef HALLOWEEN
		if(halloween_mode && prob(15))
			src.reagents.add_reagent("blood",40)
#endif

	process()
		if(!on || (world.time < src.last_spray + SPRAY_DELAY))
			return

		if(status & (NOPOWER)) //It has a powered pump or something.
			src.on = 0
			UnsubscribeProcess()
			return

		src.spray()

	proc/spray()
		src.last_spray = world.time
		if (src?.default_reagent)
			src.reagents.add_reagent(default_reagent,120)
			//also add some water for ~wet floor~ immersion
			if (src.add_water)
				src.reagents.add_reagent("water",40)

		if (src?.reagents.total_volume) //We still have reagents after, I dunno, a potassium reaction

			// "blood - 2.7867e-018" because remove_any() uses ratios (Convair880).
			for (var/current_id in src.reagents.reagent_list)
				if (isnull(src.reagents.reagent_list[current_id]))
					stack_trace("[identify_object(src)] had `[current_id]` in its reagent list, but the value was null")
					continue
				var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
				if (current_reagent.id == "water" || current_reagent.id == "cleaner")
					continue
				if (current_reagent.volume < 0.5)
					src.reagents.del_reagent(current_reagent.id)

			var/datum/effects/system/steam_spread/steam = new /datum/effects/system/steam_spread
			steam.set_up(5, 0, get_turf(src))
			steam.attach(src)
			steam.start()

			for (var/turf/T in view(1, get_turf(src))) // View and oview are unreliable as heck, apparently?
				if (!T.ocean_canpass()) continue
				SPAWN(0)
					src.reagents.reaction(T, 1, 40)
				for(var/atom/movable/AM as anything in T)
					// Added. We don't care about unmodified shower heads, though (Convair880).
					if (ismob(AM))
						var/mob/M = AM
						if (!isdead(M))
							if ((!src.reagents.has_reagent("water") && !src.reagents.has_reagent("cleaner")) || ((src.reagents.has_reagent("water") && src.reagents.has_reagent("cleaner")) && length(src.reagents.reagent_list) > 2))
								logTheThing(LOG_CHEMISTRY, M, "is hit by chemicals [log_reagents(src)] from a shower head at [log_loc(M)].")

					spawn(0)
						src.reagents.reaction(AM, 1, 40) // why the FUCK was this ingest ?? ?? ? ?? ? ?? ? ?? ? ???

		SPAWN(5 SECONDS)
			if (src?.reagents?.total_volume)
				src.reagents.del_reagent(default_reagent)
				src.reagents.remove_any(40)

		src.use_power(50)
		return

//prototypist requisition: cool futuristic shower, much less messy
/obj/machinery/sonic_shower
	name = "sonic shower head"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "sonicshower"
	desc = "Removes muck and grime with the amazing power of sound!"
	dir = NORTH
	anchored = ANCHORED
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WIRECUTTERS

	var/on = 0 //Are we currently spraying???
	var/tmp/last_spray = 0
	var/list/clean_desc = list("uncomfortably clean","scoured to the bone","cleansed and repositioned","like your atoms were scrubbed")

	New()
		..()
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "toggle", PROC_REF(mechcomp_toggle))
		src.shower_offset()

	proc/mechcomp_toggle()
		src.toggle(null)

	was_deconstructed_to_frame(mob/user)
		if (src.on)
			src.toggle(user)

	was_built_from_frame(mob/user, newly_built)
		. = ..()
		src.shower_offset()

	proc/shower_offset()
		switch(src.dir)
			if(NORTH)
				src.pixel_x = 0
				src.pixel_y = 22
			if(EAST)
				src.pixel_x = 8
				src.pixel_y = 8
			if(WEST)
				src.pixel_x = -8
				src.pixel_y = 8
			if(SOUTH)
				src.pixel_x = 0
				src.pixel_y = 0

	attack_ai(mob/user as mob)
		src.toggle(user)

	attack_hand(mob/user)
		src.toggle(user)

	proc/toggle(mob/user)
		src.on = !src.on
		if (src.on)
			SubscribeToProcess()
		else
			UnsubscribeProcess()
		if (user)
			boutput(user, "You turn [src.on ? "on" : "off"] \the [src].")

	process()
		if(!on || (world.time < src.last_spray + SPRAY_DELAY))
			return

		if(status & (NOPOWER))
			src.on = 0
			UnsubscribeProcess()
			return

		src.spray()

	proc/spray()
		var/cleaned_a_nerd = FALSE
		src.last_spray = world.time

		for (var/atom/A in range(0, get_turf(src)))
			if (A == src) continue
			if (isobj(A))
				A?.clean_forensic()
			if (ismob(A))
				var/mob/M = A
				if (!isdead(M))
					M.clean_forensic()
					M.delStatus("marker_painted")
					boutput(M,SPAN_BOLD("You feel [pick(clean_desc)]."))
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						H.sims?.affectMotive("Hygiene", 100)
					if(prob(1))
						random_brute_damage(M, 1)
					cleaned_a_nerd = TRUE

		if(cleaned_a_nerd)
			playsound(src.loc, 'sound/effects/screech.ogg', 50, 0, 0, 0.7)
			FLICK("sonicshower-on",src)
			src.use_power(750)

		return

#undef SPRAY_DELAY
