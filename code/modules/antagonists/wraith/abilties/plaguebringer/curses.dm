////////////////////////
// Curses
////////////////////////
ABSTRACT_TYPE(/datum/targetable/wraithAbility/curse)
/datum/targetable/wraithAbility/curse
	name = "<h1>This is broken!! Make a bug report!!</h1>"
	icon_state = "skeleton"
	pointCost = 40
	cooldown = 45 SECONDS
	/// Bioeffect ID of the curse this applies
	var/curse_id
	/// Description of the curse, for use in the format "we curse the target with [curse_description]."
	var/curse_description

	cast(atom/target)
		if (istype(get_area(target), /area/station/chapel))	//Dont spam curses in the chapel.
			boutput(holder.owner, "<span class='alert'>The holy ground this creature is standing on repels the curse immediatly.</span>")
			boutput(target, "<span class='alert'>You feel as though some weight was added to your soul, but the feeling immediatly dissipates.</span>")
			return FALSE

		//Lets let people know they have been cursed, might not be obvious at first glance
		var/mob/living/L = target
		if (L.traitHolder.hasTrait("training_chaplain"))
			boutput(holder.owner, "<span class='notice'>A strange force prevents you from cursing this being, your energy is wasted.</span>")
			return FALSE
		var/curseCount = 0
		if (L.bioHolder.HasEffect("blood_curse"))
			curseCount++
		if (L.bioHolder.HasEffect("blind_curse"))
			curseCount++
		if (L.bioHolder.HasEffect("weak_curse"))
			curseCount++
		if (L.bioHolder.HasEffect("rot_curse"))
			curseCount++
		switch(curseCount)
			if (1)
				boutput(L, "<span class='alert'>You feel strangely sick.</span>")
			if (2)
				boutput(L, "<span class='alert'>You hear whispers in your head, pushing you towards your doom.</span>")
				L.playsound_local(L.loc, "sound/voice/wraith/wraithstaminadrain.ogg", 50)
			if (3)
				boutput(L, "<span class='alert'><b>A cacophony of otherworldly voices resonates within your mind. You sense a feeling of impending doom! You should seek salvation in the chapel or the purification of holy water.</b></span>")
				L.playsound_local(L.loc, "sound/voice/wraith/wraithraise1.ogg", 80)
			// will never be 4, as at the most this will be the 4th

		// Put all the curses on cooldown
		for (var/datum/targetable/ability in src.holder.abilities)
			if (istype(ability, /datum/targetable/wraithAbility/curse))
				ability.doCooldown()

		src.holder.owner.playsound_local(src.holder.owner, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
		boutput(src.holder.owner, "<span class='notice'>We curse this being with [src.curse_description].</span>")
		L.bioHolder.AddEffect(src.curse_id)

	castcheck(atom/target)
		. = ..()
		var/mob/living/L = target
		if(L.bioHolder.HasEffect(src.curse_id))
			boutput(holder.owner, "<span class='alert>That curse is already applied to this being...</span>")
			return FALSE

/datum/targetable/wraithAbility/curse/blood
	name = "Curse of blood"
	icon_state = "bloodcurse"
	desc = "Curse the living with a plague of blood."
	curse_id = "blood_curse"
	curse_description = "a blood dripping curse"

/datum/targetable/wraithAbility/curse/blindness
	name = "Curse of blindness"
	icon_state = "blindcurse"
	desc = "Curse the living with blindness."
	curse_id = "blind_curse"
	curse_description = "a blinding curse"

/datum/targetable/wraithAbility/curse/enfeeble
	name = "Curse of weakness"
	icon_state = "weakcurse"
	desc = "Curse the living with weakness and lower stamina regeneration."
	curse_id = "weak_curse"
	curse_description = "an enfeebling curse"

/datum/targetable/wraithAbility/curse/rot
	name = "Curse of rot"
	icon_state = "rotcurse"
	desc = "Curse the living with a netherworldly plague."
	curse_id = "rot_curse"
	curse_description = "a decaying curse"

/// Only castable if you already put 4 curses on someone. Typed differently because it behaves differently to the others
/datum/targetable/wraithAbility/death_curse
	name = "Curse of death"
	icon_state = "deathcurse"
	desc = "Reap a fully cursed being's soul!"
	pointCost = 80
	cooldown = 45 SECONDS

	cast(atom/target)
		. = ..()
		var/mob/living/L = target
		var/mob/living/intangible/wraith/W = src.holder.owner
		L.playsound_local(L.loc, 'sound/voice/wraith/wraithhaunt.ogg', 40, 0)
		L.bioHolder.AddEffect("death_curse")
		boutput(W, "<span class='alert'><b>That soul will be OURS!</b></span>")
		SPAWN(0) // sleeps a lot
			do_curse(L, W)
		return FALSE

	castcheck(atom/target)
		. = ..()
		var/mob/living/L = target
		if(L?.bioHolder.HasEffect("death_curse"))
			boutput(holder.owner, "That curse is already applied to this being...")
			return TRUE
		if (!(L?.bioHolder.HasEffect("rot_curse") && L?.bioHolder.HasEffect("weak_curse") && \
				L?.bioHolder.HasEffect("blind_curse") && L?.bioHolder.HasEffect("blood_curse")))
			boutput(holder.owner, "<span class='alert'>That being's soul is not weakened enough. We need to curse it some more.</span>")
			return FALSE

	proc/do_curse(var/mob/living/L, var/mob/living/intangible/wraith/W)
		var/cycles = 0
		var/active = TRUE
		while (active)
			if (!L?.bioHolder.GetEffect("death_curse"))
				boutput(W, "<span class='alert'>Those foolish mortals stopped your deadly curse before it claimed it's victim! You'll damn them all!</span>")
				active = FALSE
				return
			if (!isdead(L))
				hit_twitch(L)
				random_brute_damage(L, (cycles / 3))
				cycles++
				if (prob(6))
					L.changeStatus("stunned", 2 SECONDS)
					boutput(L, "<span class='alert'><b>You feel netherworldly hands grasping at your soul!</b></span>")
				if (prob(4))
					boutput(L, "<span class='alert'>IT'S COMING FOR YOU!</span>")
					L.remove_stamina(rand(30, 70))
				if ((cycles > 10) && prob(15))
					random_brute_damage(L, 1)
					playsound(L.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 70, 1)
					L.visible_message("<span class='alert'>[L]'s flesh tears open before your very eyes!!</span>", \
										"<span class='alert'>Your flesh tears open!!</span>")
					new /obj/decal/cleanable/blood/drip(get_turf(L))
			else
				var/turf/T = get_turf(L)
				var/datum/effects/system/bad_smoke_spread/S = new /datum/effects/system/bad_smoke_spread/(T)
				if (S)
					S.set_up(8, 0, T, null, "#000000")
					S.start()
				T.fluid_react_single("miasma", 60, airborne = 1)
				var/datum/abilityHolder/wraith/AH = W.abilityHolder
				L.gib()
				AH.regenRate += 2.0
				AH.corpsecount++
				active = FALSE
			sleep (1.5 SECONDS)
