// Foam
// Similar to smoke, but spreads out more
// metal foams leave behind a foamed metal wall

/obj/effects/foam
	name = "foam"
	icon_state = "foam"
	opacity = 0
	anchored = 1
	density = 0
	layer = OBJ_LAYER + 0.9
	plane = PLANE_NOSHADOW_BELOW
	mouse_opacity = 0
	event_handler_flags = USE_HASENTERED | USE_CANPASS
	var/foamcolor
	var/amount = 3
	var/expand = 1
	animate_movement = 0
	var/metal = 0
	var/foam_id = null
	var/transferred_contents = 0 //Did we transfer our contents to another foam?
	var/repeated_applications = 0 //bandaid for foam being abuseable by spamming chem group... diminishing returns. only works if the repeated application is on the same tile (chem dispensers!!)

/*
/obj/effects/foam/New(loc, var/ismetal=0)
	..(loc)

*/

/obj/effects/foam/proc/update_icon()

	src.overlays.len = 0
	icon_state = metal ? "mfoam" : "foam"
	if(src.reagents && !metal)
		src.foamcolor = src.reagents.get_master_color()
		var/icon/I = new /icon('icons/effects/effects.dmi',"foam_overlay")
		I.Blend(src.foamcolor, ICON_ADD)
		src.overlays += I

/obj/effects/foam/pooled()
	..()
	name = "foam"
	icon_state = "foam"
	opacity = 0
	foamcolor = null
	expand = 0
	amount = 0
	metal = 0
	animate_movement = 0
	foam_id = null
	transferred_contents = 0
	if(reagents)
		reagents.clear_reagents()

/obj/effects/foam/unpooled()
	..()
	amount = 3
	expand = 1

/obj/effects/foam/proc/set_up(loc, var/ismetal)
	src.set_loc(loc)
	expand = 1
	if(!ismetal && reagents)
		reagents.inert = 1 //Wait for it...

	metal = ismetal
	//NOW WHO THOUGH IT WOULD BE A GOOD IDEA TO PLAY THIS ON EVERY FOAM OBJ
	//playsound(src, "sound/effects/bubbles2.ogg", 80, 1, -3)

	update_icon()
	if(metal)
		if(istype(loc, /turf/space))
			loc:ReplaceWithMetalFoam(metal)
	SPAWN_DBG(3 + metal*3)
		process()
	SPAWN_DBG(12 SECONDS)
		expand = 0 // stop expanding
		sleep(3 SECONDS)

		if(metal)
			var/obj/foamedmetal/M = new(src.loc)
			M.metal = metal
			M.updateicon()

		if(metal)
			flick("mfoam-disolve", src)
		else
			flick("foam-disolve", src)
		sleep(0.5 SECONDS)
		die()
	return

// on delete, transfer any reagents to the floor & surrounding tiles
/obj/effects/foam/proc/die()
	expand = 0
	if(!metal && reagents && !transferred_contents) //We don't want a foam that's done the transfer to do it's own thing
		reagents.inert = 0 //It's go time!
		reagents.postfoam = 1
		reagents.handle_reactions()
		for(var/atom/A in src.loc)
			if(A == src || istype(A, /obj/overlay) || istype(A, /obj/effects))
				continue
			if(isliving(A))
				var/mob/living/L = A
				logTheThing("combat", L, null, "is hit by chemical foam [log_reagents(src)] at [log_loc(src)].")
			if (reagents)
				reagents.reaction(A, TOUCH, 5, 0)
		if (reagents)
			reagents.reaction(src.loc, TOUCH, 5, 0)
			reagents.postfoam = 0
	pool(src)

/obj/effects/foam/proc/process()
	if(--amount < 0)
		return


	while(expand)	// keep trying to expand while true

		for(var/direction in cardinal)
			var/turf/T = get_step(src,direction)
			if(!T)
				continue

			if(T.loc:sanctuary || !T.Enter(src))
				continue

			//if(istype(T, /turf/space))
			//	continue

			var/obj/effects/foam/F = locate() in T
			if(F)
				//There's clearly foam in this turf. Make sure we haven't spread into this one already
				var/no_merge = 0

				for(var/obj/effects/foam/Fo in T)
					if (Fo.foam_id == src.foam_id )
						no_merge=1
						break

				if(no_merge) continue
				//If we haven't, then transfer our reagents to the new one.
				//But only if we aren't a metal foam and we haven't dumped our contents already... or the other one is.
				if(!(F.transferred_contents || src.transferred_contents || F.metal || src.metal))

					if (src.reagents) src.reagents.copy_to(F.reagents)
					F.update_icon()

					src.transferred_contents=1


			F = unpool(/obj/effects/foam)
			F.set_up(T, metal)
			F.amount = amount
			F.foam_id = src.foam_id //Just keep track of us being from the same source
			if(!metal && src.reagents)
				F.overlays.len = 0
				F.create_reagents(15)
				F.reagents.inert = 1
				//This very slight tweak is to make it so some reactions that require different ratios
				//can still work in foam.
				for(var/reagent_id in src.reagents.reagent_list)
					var/datum/reagent/current_reagent = src.reagents.reagent_list[reagent_id]
					if(current_reagent)
						F.reagents.add_reagent(reagent_id,min(current_reagent.volume, 3), current_reagent.data, src.reagents.total_temperature)

				F.update_icon()

		sleep(1.5 SECONDS)

// foam disolves when heated
// except metal foams
/obj/effects/foam/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!metal && prob(max(0, exposed_temperature - 475)))
		flick("foam-disolve", src)

		SPAWN_DBG(0.5 SECONDS)
			die()
			expand = 0


/obj/effects/foam/HasEntered(var/atom/movable/AM)
	if (metal || transferred_contents) //If we've transferred our contents then there's another foam tile that can do it thing.
		return

	if (ishuman(AM))
		var/mob/living/carbon/human/M = AM

		if (M.slip())
			if (src.reagents) //Wire note: Fix for Cannot read null.reagent_list
				for(var/reagent_id in src.reagents.reagent_list)
					var/amount = M.reagents.get_reagent_amount(reagent_id)
					if(amount < 25)
						M.reagents.add_reagent(reagent_id, 5)

			logTheThing("combat", M, null, "is hit by chemical foam [log_reagents(src)] at [log_loc(src)].")
			reagents.reaction(M, TOUCH, 5)

			M.show_text("You slip on the foam!", "red")

/obj/effects/foam/CanPass(atom/movable/mover, turf/target)
	if (src.metal && !mover)
		return 0 // completely opaque to air
	return 1
