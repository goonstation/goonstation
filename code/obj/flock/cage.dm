/////////////////////////////////////////////////////////////////////////////////
// ENERGY CAGE
/////////////////////////////////////////////////////////////////////////////////
/obj/flock_structure/cage
	name = "weird energy cage"
	desc = "You can see the person inside being rapidly taken apart by fibrous mechanisms. You ought to do something about that."
	flock_desc = "Spins living matter into Flockdrones. Painfully."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "cage"
	flock_id = "Matter reprocessor"
	flags = USEDELAY
	health = 30
	health_max = 30
	alpha = 192
	anchored = FALSE
	hitTwitch = FALSE
	passthrough = TRUE
	var/atom/occupant = null
	var/obj/target = null
	var/eating_occupant = FALSE
	var/initial_volume = 200
	// convert things into different fluids, convert those fluids into coagulated gnesis, convert 50 of that into an egg
	var/target_fluid = "flockdrone_fluid"
	var/create_egg_at_fluid = 100
	var/absorb_per_process_tick = 2


	New(loc, var/atom/iced, datum/flock/F=null)
		..(loc,F)
		if(iced && !isAI(iced) && !isblob(iced) && !iswraith(iced))
			if(istype(iced.loc, /obj/flock_structure/cage))
				qdel(src)
				return

			if(!(ismob(iced) || iscritter(iced)))
				qdel(src)
				return
			iced:set_loc(src)

			boutput(iced, "<span class='alert'>You are trapped within [src]!</span>")

		src.create_reagents(initial_volume)

		if(iced)
			if(istype(iced,/mob/living))
				var/mob/living/M = iced
				M.addOverlayComposition(/datum/overlayComposition/flockmindcircuit)
			occupant = iced

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
		if(length(organs) >= 2)
			organs -= brain
		if(length(items))
			eating_occupant = FALSE
			target = pick(items)
			H.remove_item(target)
			playsound(src, 'sound/weapons/nano-blade-1.ogg', 50, 1)
			boutput(H, "<span class='alert'>[src] pulls [target] from you and begins to rip it apart.</span>")
			src.visible_message("<span class='alert'>[src] pulls [target] from [H] and begins to rip it apart.</span>")
		else if(length(limbs))
			eating_occupant = TRUE
			target = pick(limbs)
			H.limbs.sever(target)
			H.emote("scream")
			random_brute_damage(H, 20)
			playsound(src, 'sound/impact_sounds/Flesh_Tear_1.ogg', 80, 1)
			boutput(H, "<span class='alert bold'>[src] wrenches your [initial(target.name)] clean off and begins peeling it apart! Fuck!</span>")
			src.visible_message("<span class='alert bold'>[src] wrenches [target.name] clean off and begins peeling it apart!</span>")
			flock.achieve(FLOCK_ACHIEVEMENT_CAGE_HUMAN)
		else if(length(organs))
			eating_occupant = TRUE
			target = pick(organs)
			H.drop_organ(target)
			H.emote("scream")
			random_brute_damage(H, 20)
			playsound(src, 'sound/impact_sounds/Flesh_Tear_2.ogg', 80, 1)
			boutput(H, "<span class='alert bold'>[src] tears out your [initial(target.name)]! OH GOD!</span>")
			src.visible_message("<span class='alert bold'>[src] tears out [target.name]!</span>")
			flock.achieve(FLOCK_ACHIEVEMENT_CAGE_HUMAN)
		else
			H.gib()
			occupant = null
			playsound(src, 'sound/impact_sounds/Flesh_Tear_2.ogg', 80, 1)
			src.visible_message("<span class='alert bold'>[src] rips what's left of its occupant to shreds!</span>")

	proc/getRobotPiece(mob/living/silicon/robot/R)
		// prefer inventory items before limbs, and limbs before organs
		var/list/organs = list()
		var/list/limbs = list()
		var/list/items = list()
		var/obj/item/organ/brain/brain = null
		for(var/obj/item/I in R.contents)
			if(istype(I, /obj/item/parts/robot_parts/head) || istype(I, /obj/item/parts/robot_parts/chest))
				continue // taking container organs is kinda too cheap
			if(istype(I, /obj/item/organ) || istype(I, /obj/item/clothing/head/butt))
				organs += I
				if(istype(I, /obj/item/organ/brain))
					brain = I
			else if(istype(I, /obj/item/parts))
				limbs += I
			else if(istype(I,/obj/item/clothing))
				items += I
			//anything else is gonna be a borg tool, so ignore those

		// only take the brain as the very last thing
		if(length(organs) >= 2)
			organs -= brain
		if(length(items))
			eating_occupant = FALSE
			target = pick(items)
			R.remove_item(target)
			playsound(src, 'sound/weapons/nano-blade-1.ogg', 50, 1)
			boutput(R, "<span class='alert'>[src] pulls [target] from you and begins to rip it apart.</span>")
			src.visible_message("<span class='alert'>[src] pulls [target] from [R] and begins to rip it apart.</span>")
		else if(length(limbs))
			eating_occupant = TRUE
			target = pick(limbs)
			R.compborg_lose_limb(target)
			R.emote("scream")
			random_brute_damage(R, 20)
			playsound(src, 'sound/impact_sounds/Flesh_Tear_1.ogg', 80, 1)
			boutput(R, "<span class='alert bold'>[src] wrenches your [initial(target.name)] clean off and begins peeling it apart! Fuck!</span>")
			src.visible_message("<span class='alert bold'>[src] wrenches [target.name] clean off and begins peeling it apart!</span>")
		else if(length(organs))
			eating_occupant = TRUE
			target = pick(organs)
			R.compborg_lose_limb(target)
			R.emote("scream")
			random_brute_damage(R, 20)
			playsound(src, 'sound/impact_sounds/Flesh_Tear_2.ogg', 80, 1)
			boutput(R, "<span class='alert bold'>[src] tears out your [initial(target.name)]! OH GOD!</span>")
			src.visible_message("<span class='alert bold'>[src] tears out [target.name]!</span>")
		else
			R.gib()
			occupant = null
			playsound(src, 'sound/impact_sounds/Flesh_Tear_2.ogg', 80, 1)
			src.visible_message("<span class='alert bold'>[src] rips what's left of its occupant to shreds!</span>")
			flock.achieve(FLOCK_ACHIEVEMENT_CAGE_HUMAN)

	proc/spawnEgg()
		src.visible_message("<span class='notice'>[src] spits out a device!</span>")
		var/obj/flock_structure/egg/egg = new(get_turf(src), src.flock)
		var/turf/target = null
		target = get_edge_target_turf(get_turf(src), pick(alldirs))
		egg.throw_at(target, 12, 3)

	process()
		// process fluids into stuff
		if(reagents.has_reagent(target_fluid, create_egg_at_fluid))
			if (src.flock?.getComplexDroneCount() < FLOCK_DRONE_LIMIT)
				spawnEgg()
			else
				var/obj/item/flockcache/cube = new(get_turf(src))
				cube.resources = create_egg_at_fluid
			reagents.remove_reagent(target_fluid, create_egg_at_fluid)

		if(occupant && src.flock)
			src.flock.updateEnemy(occupant)
		// process stuff into fluids
		if(isnull(target))
			// find a new thing to eat
			var/list/edibles = list()
			for(var/obj/O in src.contents)
				edibles += O
			if(length(edibles))
				target = pick(edibles)
				eating_occupant = FALSE
				playsound(src, 'sound/weapons/nano-blade-1.ogg', 50, 1)
				if(occupant)
					boutput(occupant, "<span class='notice'>[src] begins to process [target].</span>")
			else if(occupant && ishuman(occupant))
				var/mob/living/carbon/human/H = occupant
				getHumanPiece(H) //cut off a human part and add it to contents, set it to target
				H?.reagents?.add_reagent(target_fluid,2) //you get a bit of juice, just to complicate life
			else if(occupant && isrobot(occupant))
				var/mob/living/silicon/robot/H = occupant
				getRobotPiece(H) //cut off a robot part and add it to contents, set it to target
			else if(isliving(occupant))
				eating_occupant = TRUE
				var/mob/living/M = occupant
				target = M //set target to the mob
			else if(iscritter(occupant))
				eating_occupant = TRUE
				var/obj/critter/C = occupant
				C.CritterDeath() //kill obj/critters immediately because their behaviour is jank and awful
				target = C //set target to the critter

			if(target)
				target.set_loc(src)
		else
			if(hasvar(target, "health"))
				var/absorption = min(absorb_per_process_tick, target:health)
				if (ismob(target))
					var/mob/M = target
					M.TakeDamage(brute = absorption)
				else
					target:health -= absorption
				reagents.add_reagent(target_fluid, absorption * 2)
				if(target:health <= 0)
					if(isliving(target))
						var/mob/living/M = target
						M.set_loc(src)
						M.gib()
						occupant = null
						playsound(src, 'sound/impact_sounds/Flesh_Tear_2.ogg', 80, 1)
						src.visible_message("<span class='alert bold'>[src] rips what's left of its occupant to shreds!</span>")
					else
						if(iscritter(target))
							occupant = null
							playsound(src, 'sound/impact_sounds/Flesh_Tear_2.ogg', 80, 1)
							src.visible_message("<span class='alert bold'>[src] rips what's left of its occupant to shreds!</span>")
					target.set_loc(null)
					qdel(target)
					target = null
			else
				reagents.add_reagent(target_fluid, 10)
				qdel(target)
				target = null

		if(occupant)
			if(eating_occupant && prob(20))
				boutput(occupant, "<span class='flocksay italics'>[pick_string("flockmind.txt", "flockmind_conversion")]</span>")
		if(!length(src.contents) && reagents.get_reagent_amount(target_fluid) < create_egg_at_fluid)
			if(reagents.has_reagent(target_fluid)) // dump out our excess resources as a cache
				playsound(src, 'sound/impact_sounds/Slimy_Splat_1.ogg', 80, 1)
				var/obj/item/flockcache/x = new(src.loc)
				x.resources = reagents.get_reagent_amount(target_fluid)
				reagents.del_reagent(target_fluid,x.resources)
			qdel(src)

	disposing()
		playsound(src, 'sound/impact_sounds/Energy_Hit_2.ogg', 80, 1)
		if (src.reagents) //spill out your contents
			src.reagents.reaction(get_turf(src))

		if(istype(occupant,/mob/living))
			var/mob/living/M = occupant
			M?.removeOverlayComposition(/datum/overlayComposition/flockmindcircuit)

		for(var/atom/movable/AM in src)
			if(ismob(AM))
				var/mob/M = AM
				M.visible_message("<span class='alert'><b>[M]</b> breaks out of [src]!</span>","<span class='alert'>You break out of [src]!</span>")
			AM.set_loc(src.loc)
		..()

	relaymove(mob/user as mob)
		if (user.stat)
			return
		if(ON_COOLDOWN(src,"move_damage",1 SECOND))
			return
		if(prob(75))
			if (!ON_COOLDOWN(src, "move_msg", 3 SECONDS))
				user.show_text("<span class='alert'>[src] [pick("cracks","bends","shakes","groans")].</span>")
			user.playsound_local(src.loc, 'sound/impact_sounds/Crystal_Hit_1.ogg', 50, 1)
			takeDamage("brute",1)

	takeDamage(var/damageType, var/amount)
		..(damageType,amount)
		var/wiggle = 3
		SPAWN(0)
			while(wiggle > 0)
				wiggle--
				src.pixel_x = rand(-2,2)
				src.pixel_y = rand(-2,2)
				sleep(0.5)
			src.pixel_x = 0
			src.pixel_y = 0

	checkhealth()
		if(src.health <= 0)
			qdel(src)

	mob_resist_inside(var/mob/user)
		if (ON_COOLDOWN(src, "resist_damage", 3 SECONDS))
			return
		ON_COOLDOWN(src, "move_damage", 1 SECOND)
		user.show_text("<span class='alert'>[src] [pick("begins to splinter","cracks open slightly","becomes a little less solid","loosens around you")].</span>")
		src.takeDamage("brute",6)
		user.playsound_local(src, "sound/misc/flockmind/flockdrone_grump[pick(1,2,3)].ogg", 50, 1, 0, 0.5 )
		return TRUE

	mob_flip_inside(var/mob/user)
		..(user)
		src.mob_resist_inside(user)

	special_desc(dist, mob/user)
		if (!isflockmob(user))
			return
		return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
			<br><span class='bold'>ID:</span> Matter Reprocessor
			<br><span class='bold'>System Integrity:</span> [round((src.health/src.health_max)*100)]%
			<br><span class='bold'>Volume:</span> [src.reagents.get_reagent_amount(src.target_fluid)]
			<br><span class='bold'>Needed volume:</span> [src.create_egg_at_fluid]
			<br><span class='bold'>###=-</span></span>"}



