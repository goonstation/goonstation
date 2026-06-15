ABSTRACT_TYPE(/obj/item/implant/revenge)
/// Abstract supertype for implants that do something explodey-ish when you die. Includes functionality for scaling with implant number
/obj/item/implant/revenge
	name = "YOU SHOULDN'T SEE THIS - TELL A CODER"
	icon_state = "implant-r"
	impcolor = "r"
	instant = TRUE
	scan_category = IMPLANT_SCAN_CATEGORY_SYNDICATE
	var/active = FALSE
	var/power = 1 //! Means different things for different implants, but in a general sense how Powerful the effect is. Scales additively with implant number.
	var/big_message = " fucks up really bad why did you do this"
	var/small_message = " just fucks up a little bit"

	on_death()
		SHOULD_CALL_PARENT(TRUE)
		..()
		// The way this works sorta sucks. We have N implants, but we only want a single effect, scaled by the value of N.
		// So we just run this on_death code for every implant, but the first implant to run it marks all the others as 'active',
		// and if an implant is already 'active' then it does nothing on death.
		if (!src.active)
			var/power = 0
			for (var/obj/item/implant/implant in src.loc)
				if (istype(implant, src.type)) //only interact with implants that are the same type as us
					var/obj/item/implant/revenge/revenge_implant = implant
					if (!revenge_implant.active)
						revenge_implant.active = TRUE
						power += revenge_implant.power //tally the total power we're dealing with here

			// If you're suiciding and unlucky, all the power just goes out the window and we don't trigger
			var/mob/living/source = owner
			if(source.suiciding && prob(60)) //Probably won't trigger on suicide though
				source.visible_message("[source] emits a somber buzzing noise.")
				return
			src.do_effect(power)

			var/area/A = get_area(source)
			if (!A.dont_log_combat)
				logTheThing(LOG_BOMBING, source, "triggered \a [src] on death at [log_loc(source)].")
				message_admins("[key_name(source)] triggered \a [src] on death at [log_loc(source)].")

	/// This is where you put the actual effect the implant has on death (some kind of an explosion probably)
	/// You probably want to call this parent after exploding or whatever
	proc/do_effect(power)
		SHOULD_CALL_PARENT(TRUE)
		if (power >= 6)
			src.owner.visible_message(SPAN_ALERT("<b>[src.owner][big_message]!</b>"))
		else
			src.owner.visible_message("[src.owner][small_message].")

/obj/item/implant/revenge/microbomb
	name = "microbomb implant"
	big_message = " emits a loud clunk"
	small_message = " makes a small clicking noise"

	can_implant(mob/target, mob/user)
		if(!..())
			return FALSE
		if (isghostcritter(target) || ishelpermouse(target))
			return FALSE
		return TRUE


	implanted(mob/target, mob/user)
		..()
		if (target == user)
			target.mind.store_memory("Your implanted [src] will detonate upon unintentional death.", 0, 0)
			boutput(target, "The implanted [src] will detonate upon unintentional death. (Suiciding will likely fail to trigger it, but succumbing while in crit will trigger it.)")
		else if (istype(user))
			boutput(user, "The implanted [src] will detonate upon [target]'s unintentional death.")


	do_effect(power)
		var/turf/T = get_turf(src)

		var/obj/overlay/Ov = new/obj/overlay(T)
		Ov.anchored = ANCHORED //Create a big bomb explosion overlay.
		Ov.name = "Explosion"
		Ov.layer = NOLIGHT_EFFECTS_LAYER_BASE
		Ov.pixel_x = -92
		Ov.pixel_y = -96
		Ov.icon = 'icons/effects/214x246.dmi'
		Ov.icon_state = "explosion"

		SPAWN(1.5 SECONDS) //Delete the overlay when finished with it.
			qdel(Ov)

		SPAWN(1)
			T.hotspot_expose(800,125)
			explosion_new(src, T, 7 * power, 1) //power is the tally of explosionPower in this poor slob.
			if (ishuman(src.owner))
				var/mob/living/carbon/human/H = src.owner
				H.dump_contents_chance = 80 //hee hee
			src.owner?.gib() //yer DEAD
		. = ..()

/obj/item/implant/revenge/microbomb/hunter
	power = 4

/obj/item/implant/revenge/zappy
	name = "flyzapper implant" //todo better name idk
	big_message = " begins radiating electricity"
	small_message = "'s hair starts standing on end"
	power = 3

	// this is kinda horribly inefficient but it runs pretty rarely so eh
	do_effect(power)
		elecflash(src, power, power * 2, TRUE)
		for (var/mob/living/M in orange(power / 6 + 1, src.owner))
			if (!isintangible(M))
				var/dist = GET_DIST(src.owner, M) + 1
				// arcflash uses some fucked up thresholds so trust me on this one
				arcFlash(src.owner, M, (40000 * (4 - (0.4 * dist * log(dist)))) * (15 * log(max(1, power)) + 3))
		for (var/obj/machinery/machine in orange(round(power / 6) + 1)) // machinery around you also zaps people, based on the amount of power in the grid
			if (prob(power * 7))
				var/mob/living/target
				for (var/mob/living/L in orange(machine, 2))
					if (!isintangible(L))
						target = L
						break
				if (target)
					arcFlash(src, target, 100000) //TODO scale this with powergrid... somehow. get area APC or smth

		SPAWN(1)
			src.owner?.elecgib()
		. = ..()

/obj/item/implant/revenge/wasp
	name = "wasp implant"
	big_message = " buzzes, what?"
	small_message = "buzzes loudly, uh oh!"
	power = 8
	var/wasp_type = /mob/living/critter/small_animal/wasp/angry
	var/faction = FACTION_BOTANY

	implanted(mob/M, mob/I)
		..()
		if (istype(M) && src.faction)
			LAZYLISTADDUNIQUE(M.faction, src.faction)

	on_remove(mob/M)
		..()
		if (istype(M) && src.faction)
			LAZYLISTREMOVE(M.faction, src.faction)

	do_effect(power)
		// enjoy your wasps
		for (var/i in 1 to power)
			var/throw_type = THROW_NORMAL
			var/mob/M = new src.wasp_type(get_turf(src))
			if(ismob(M))
				M.lying = TRUE // So wasps dont hit other wasps when being flung
				SPAWN(1 SECOND)
					M.lying = FALSE
			else
				throw_type = THROW_PHASE
			M.throw_at(get_edge_target_turf(get_turf(src), pick(alldirs)), rand(1,3 + round(power / 16)), 2, throw_type = throw_type)

		SPAWN(1)
			src.owner?.gib()
		. = ..()
