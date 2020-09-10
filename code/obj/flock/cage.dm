/////////////////////////////////////////////////////////////////////////////////
// ENERGY CAGE
/////////////////////////////////////////////////////////////////////////////////
// it's just an ice cube, but stronger and it looks different
// and eats people, i guess, too
/obj/icecube/flockdrone
	name = "weird energy cage"
	desc = "You can see the person inside being rapidly taken apart by fibrous mechanisms. You ought to do something about that."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "cage"
	steam_on_death = 0
	health = 30
	alpha = 192
	var/datum/flock/flock
	var/mob/living/occupant = null // todo: make this work with more than just humans (borgs, critters, probably not cubes)
	var/obj/target = null
	var/eating_occupant = 0
	var/initial_volume = 200
	// convert things into different fluids, convert those fluids into coagulated gnesis, convert 50 of that into an egg
	var/target_fluid = "flockdrone_fluid"
	var/create_egg_at_fluid = 100
	var/absorb_per_process_tick = 2
	mat_changename = 0
	mat_changedesc = 0
	mat_changeappearance = 0


	New(loc, mob/living/iced as mob, datum/flock/F=null)
		..()
		src.flock = F
		var/datum/reagents/R = new /datum/reagents(initial_volume)
		src.reagents = R
		R.my_atom = src //grumble
		iced.addOverlayComposition(/datum/overlayComposition/flockmindcircuit)
		occupant = iced
		processing_items |= src
		src.setMaterial(getMaterial("gnesis"))

	proc/getHumanPiece(var/mob/living/carbon/human/H)
		// prefer inventory items before limbs, and limbs before organs
		var/list/organs = list()
		var/list/limbs = list()
		var/list/items = list()
		var/obj/item/organ/brain/brain = null
		for(var/obj/item/I in H.contents)
			if(istype(I, /obj/item/organ/head) || istype(I, /obj/item/organ/chest) || istype(I, /obj/item/skull))
				continue // taking container organs is kinda too cheap
			if(istype(I, /obj/item/organ) || istype(I, /obj/item/clothing/head/butt))
				organs += I
				if(istype(I, /obj/item/organ/brain))
					brain = I
			else if(istype(I, /obj/item/parts))
				limbs += I
			else
				items += I
		// only take the brain as the very last thing
		if(organs.len >= 2)
			organs -= brain
		if(items.len >= 1)
			eating_occupant = 0
			target = pick(items)
			H.remove_item(target)
			playsound(get_turf(src), "sound/weapons/nano-blade-1.ogg", 50, 1)
			boutput(H, "<span class='alert'>[src] pulls [target] from you and begins to rip it apart.</span>")
			src.visible_message("<span class='alert'>[src] pulls [target] from [H] and begins to rip it apart.</span>")
		else if(limbs.len >= 1)
			eating_occupant = 1
			target = pick(limbs)
			H.limbs.sever(target)
			H.emote("scream")
			random_brute_damage(H, 20)
			playsound(get_turf(src), "sound/impact_sounds/Flesh_Tear_1.ogg", 80, 1)
			boutput(H, "<span class='alert bold'>[src] wrenches your [initial(target.name)] clean off and begins peeling it apart! Fuck!</span>")
			src.visible_message("<span class='alert bold'>[src] wrenches [target.name] clean off and begins peeling it apart!</span>")
		else if(organs.len >= 1)
			eating_occupant = 1
			target = pick(organs)
			H.drop_organ(target)
			H.emote("scream")
			random_brute_damage(H, 20)
			playsound(get_turf(src), "sound/impact_sounds/Flesh_Tear_2.ogg", 80, 1)
			boutput(H, "<span class='alert bold'>[src] tears out your [initial(target.name)]! OH GOD!</span>")
			src.visible_message("<span class='alert bold'>[src] tears out [target.name]!</span>")
		else
			H.gib()
			occupant = null
			underlays -= H
			playsound(get_turf(src), "sound/impact_sounds/Flesh_Tear_2.ogg", 80, 1)
			src.visible_message("<span class='alert bold'>[src] rips what's left of its occupant to shreds!</span>")

	Enter(atom/movable/O)
		. = ..()
		underlays += O

	proc/spawnEgg()
		src.visible_message("<span class='notice'>[src] spits out a device!</span>")
		var/obj/flock_structure/egg/egg = new(get_turf(src), src.flock)
		var/turf/target = null
		target = get_edge_target_turf(get_turf(src), pick(alldirs))
		egg.throw_at(target, 12, 3)

	process()
		// consume any fluid near us
		var/turf/T = get_turf(src)
		if(T && T.active_liquid)
			var/obj/fluid/F = T.active_liquid
			F.group.drain(F, 15, src)

		// process fluids into stuff
		if(reagents.has_reagent(target_fluid, create_egg_at_fluid))
			reagents.remove_reagent(target_fluid, create_egg_at_fluid)
			spawnEgg()

		// process stuff into fluids
		if(isnull(target))
			// find a new thing to eat
			var/list/edibles = list()
			for(var/obj/O in src.contents)
				edibles += O
			if(edibles.len >= 1)
				target = pick(edibles)
				eating_occupant = 0
				playsound(get_turf(src), "sound/weapons/nano-blade-1.ogg", 50, 1)
				if(occupant)
					boutput(occupant, "<span class='notice'>[src] begins to process [target].</span>")
			else if(occupant && ishuman(occupant))
				var/mob/living/carbon/human/H = occupant
				getHumanPiece(H)
			else if(occupant)
				occupant.gib() // sorry buddy but if you're some freaky-deaky cube thing or some other weird living thing we can't be doing with this now
			if(target)
				target.set_loc(src)
		else
			underlays -= target
			if(hasvar(target, "health"))
				var/absorption = min(absorb_per_process_tick, target:health)
				target:health -= absorption
				reagents.add_reagent(target_fluid, absorption * 2)
				if(target:health <= 0)
					reagents.add_reagent(target_fluid, 10)
					qdel(target)
					target = null
			else
				reagents.add_reagent(target_fluid, 10)
				qdel(target)
				target = null
		if(occupant)
			underlays -= occupant
			underlays += occupant
			if(eating_occupant && prob(20))
				boutput(occupant, "<span class='flocksay italics'>[pick_string("flockmind.txt", "flockmind_conversion")]</span>")
		if(src.contents.len <= 0 && reagents.get_reagent_amount(target_fluid) < 50)
			if(reagents.has_reagent(target_fluid)) // flood the area with our unprocessed contents
				playsound(get_turf(src), "sound/impact_sounds/Slimy_Splat_1.ogg", 80, 1)
				T.fluid_react_single(reagents.get_reagent_amount(target_fluid))
			qdel(src)

	disposing()
		playsound(get_turf(src), "sound/impact_sounds/Energy_Hit_2.ogg", 80, 1)
		processing_items -= src
		if(occupant)
			occupant.removeOverlayComposition(/datum/overlayComposition/flockmindcircuit)
		..()


/obj/icecube/flockdrone/special_desc(dist, mob/user)
	if(isflock(user))
		var/special_desc = "<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received."
		special_desc += "<br><span class='bold'>ID:</span> Matter Reprocessor"
		special_desc += "<br><span class='bold'>Volume:</span> [src.reagents.get_reagent_amount(src.target_fluid)]"
		special_desc += "<br><span class='bold'>Needed volume:</span> [src.create_egg_at_fluid]"
		special_desc += "<br><span class='bold'>###=-</span></span>"
		return special_desc
	else
		return null // give the standard description


