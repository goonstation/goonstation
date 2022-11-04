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

	var/foamcolor
	var/amount = 3
	var/expand = 1
	animate_movement = 0
	var/metal = 0
	var/foam_id = null
	var/repeated_applications = 0 //bandaid for foam being abuseable by spamming chem group... diminishing returns. only works if the repeated application is on the same tile (chem dispensers!!)

/*
/obj/effects/foam/New(loc, var/ismetal=0)
	..(loc)

*/

/obj/effects/foam/update_icon()
	src.overlays.len = 0
	icon_state = metal ? "mfoam" : "foam"
	if(src.reagents && !metal)
		src.foamcolor = src.reagents.get_master_color()
		var/icon/I = new /icon('icons/effects/effects.dmi',"foam_overlay")
		I.Blend(src.foamcolor, ICON_ADD)
		src.overlays += I

/obj/effects/foam/proc/set_up(loc, var/ismetal)
	src.set_loc(loc)
	expand = 1
	if(!ismetal && reagents)
		reagents.inert = 1 //Wait for it...

	metal = ismetal
	//NOW WHO THOUGH IT WOULD BE A GOOD IDEA TO PLAY THIS ON EVERY FOAM OBJ
	//playsound(src, 'sound/effects/bubbles2.ogg', 80, 1, -3)

	UpdateIcon()
	if(metal)
		if(istype(loc, /turf/space))
			loc:ReplaceWithMetalFoam(metal)
	SPAWN(3 + metal*3)
		process()
	SPAWN(12 SECONDS)
		expand = 0 // stop expanding
		sleep(3 SECONDS)

		if(metal)
			var/obj/foamedmetal/M = new(src.loc)
			M.metal = metal
			M.UpdateIcon()

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
	if(!metal && reagents) //We don't want a foam that's done the transfer to do it's own thing
		reagents.inert = 0 //It's go time!
		reagents.postfoam = 1
		reagents.handle_reactions()
		for(var/atom/A in src.loc)
			if(A == src || istype(A, /obj/overlay) || istype(A, /obj/effects))
				continue
			if(isliving(A))
				var/mob/living/L = A
				logTheThing(LOG_COMBAT, L, "is hit by chemical foam [log_reagents(src)] at [log_loc(src)].")
			if (reagents)
				reagents.reaction(A, TOUCH, 5, 0)
		if (reagents)
			reagents.reaction(src.loc, TOUCH, 5, 0)
			reagents.postfoam = 0
	qdel(src)

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
			var/skip = FALSE
			for(var/atom/movable/AM in T)
				if(!AM.Cross(src))
					skip = TRUE
					break
			if(skip)
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

			F = new /obj/effects/foam
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

				F.UpdateIcon()

		sleep(1.5 SECONDS)

// foam disolves when heated
// except metal foams
/obj/effects/foam/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!metal && prob(max(0, exposed_temperature - 475)))
		flick("foam-disolve", src)

		SPAWN(0.5 SECONDS)
			die()
			expand = 0


/obj/effects/foam/Crossed(atom/movable/AM)
	..()
	if (metal) //If we've transferred our contents then there's another foam tile that can do it thing.
		return

	if (ishuman(AM))
		var/mob/living/carbon/human/M = AM

		if (M.slip())
			logTheThing(LOG_COMBAT, M, "is hit by chemical foam [log_reagents(src)] at [log_loc(src)].")
			reagents.reaction(M, TOUCH, 5)

			M.show_text("You slip on the foam!", "red")


/obj/effects/foam/gas_cross(turf/target)
	if(src.metal)
		return 0 //opaque to air

//This should probably be reworked to be a subtype of /obj/effects/foam
/obj/fire_foam
	name = "Fire fighting foam"
	desc = "It's foam."
	opacity = 0
	density = 0
	anchored = 1
	icon = 'icons/effects/fire.dmi'
	icon_state = "foam"
	animate_movement = SLIDE_STEPS
	mouse_opacity = 0
	var/my_dir = null

	Move(NewLoc,Dir=0)
		. = ..(NewLoc,Dir)
		if(isnull(my_dir))
			my_dir = pick(alldirs)
		src.set_dir(my_dir)
