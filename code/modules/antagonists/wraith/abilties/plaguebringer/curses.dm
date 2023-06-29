////////////////////////
// Curses
////////////////////////
ABSTRACT_TYPE(/datum/targetable/wraithAbility/curse)
/datum/targetable/wraithAbility/curse
	name = "Base curse"
	icon_state = "skeleton"
	desc = "This should never be seen."
	targeted = 1
	pointCost = 30
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())

			return 1

		if (ishuman(target))
			if (istype(get_area(target), /area/station/chapel))	//Dont spam curses in the chapel.
				boutput(holder.owner, "<span class='alert'>The holy ground this creature is standing on repels the curse immediatly.</span>")
				boutput(target, "<span class='alert'>You feel as though some weight was added to your soul, but the feeling immediatly dissipates.</span>")
				return 0

			//Lets let people know they have been cursed, might not be obvious at first glance
			var/mob/living/carbon/H = target
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, "<span class='notice'>A strange force prevents you from cursing this being, your energy is wasted.</span>")
				return 0
			var/curseCount = 0
			if (H.bioHolder.HasEffect("blood_curse"))
				curseCount ++
			if (H.bioHolder.HasEffect("blind_curse"))
				curseCount ++
			if (H.bioHolder.HasEffect("weak_curse"))
				curseCount ++
			if (H.bioHolder.HasEffect("rot_curse"))
				curseCount ++
			switch(curseCount)
				if (1)
					boutput(H, "<span class='notice'>You feel strangely sick.</span>")
				if (2)
					boutput(H, "<span class='alert'>You hear whispers in your head, pushing you towards your doom.</span>")
					H.playsound_local(H.loc, "sound/voice/wraith/wraithstaminadrain.ogg", 50)
				if (3)
					boutput(H, "<span class='alert'><b>A cacophony of otherworldly voices resonates within your mind. You sense a feeling of impending doom! You should seek salvation in the chapel or the purification of holy water.</b></span>")
					H.playsound_local(H.loc, "sound/voice/wraith/wraithraise1.ogg", 80)

/datum/targetable/wraithAbility/curse/blood
	name = "Curse of blood"
	icon_state = "bloodcurse"
	desc = "Curse the living with a plague of blood."
	targeted = 1
	pointCost = 40
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.bioHolder.HasEffect("blood_curse"))
				boutput(holder.owner, "That curse is already applied to this being...")
				return 1
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			H.bioHolder.AddEffect("blood_curse")
			boutput(holder.owner, "<span class='notice'>We curse this being with a blood dripping curse.</span>")
			var/datum/targetable/ability = holder.getAbility(/datum/targetable/wraithAbility/curse/rot)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blindness)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/enfeeble)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/death)
			ability.doCooldown()
			return 0
		else
			return 1

/datum/targetable/wraithAbility/curse/blindness
	name = "Curse of blindness"
	icon_state = "blindcurse"
	desc = "Curse the living with blindness."
	targeted = 1
	pointCost = 40
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.bioHolder.HasEffect("blind_curse"))
				boutput(holder.owner, "That curse is already applied to this being...")
				return 1
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			H.bioHolder.AddEffect("blind_curse")
			boutput(holder.owner, "<span class='notice'>We curse this being with a blinding curse.</span>")
			var/datum/targetable/ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blood)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/enfeeble)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/rot)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/death)
			ability.doCooldown()
			return 0
		else
			return 1

/datum/targetable/wraithAbility/curse/enfeeble
	name = "Curse of weakness"
	icon_state = "weakcurse"
	desc = "Curse the living with weakness and lower stamina regeneration."
	targeted = 1
	pointCost = 40
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.bioHolder.HasEffect("weak_curse"))
				boutput(holder.owner, "That curse is already applied to this being...")
				return 1
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			H.bioHolder.AddEffect("weak_curse")
			boutput(holder.owner, "<span class='notice'>We curse this being with an enfeebling curse.</span>")
			var/datum/targetable/ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blood)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blindness)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/rot)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/death)
			ability.doCooldown()
			return 0
		else
			return 1

/datum/targetable/wraithAbility/curse/rot
	name = "Curse of rot"
	icon_state = "rotcurse"
	desc = "Curse the living with a netherworldly plague."
	targeted = 1
	pointCost = 40
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H= target
			if(H.bioHolder.HasEffect("rot_curse"))
				boutput(holder.owner, "That curse is already applied to this being...")
				return 1
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			H.bioHolder.AddEffect("rot_curse")
			boutput(holder.owner, "<span class='notice'>We curse this being with a decaying curse.</span>")
			var/datum/targetable/ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blood)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blindness)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/enfeeble)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/death)
			ability.doCooldown()
			return 0
		else
			return 1

/datum/targetable/wraithAbility/curse/death	//Only castable if you already put 4 curses on someone
	name = "Curse of death"
	icon_state = "deathcurse"
	desc = "Reap a fully cursed being's soul!"
	targeted = 1
	pointCost = 80
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return TRUE

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			var/mob/living/intangible/wraith/W = holder.owner
			if (H?.bioHolder.HasEffect("rot_curse") && H?.bioHolder.HasEffect("weak_curse") && H?.bioHolder.HasEffect("blind_curse") && H?.bioHolder.HasEffect("blood_curse"))
				W.playsound_local(W.loc, 'sound/voice/wraith/wraithhaunt.ogg', 40, 0)
				H.bioHolder.AddEffect("death_curse")
				boutput(W, "<span class='alert'><b>That soul will be OURS!</b></span>")
				do_curse(H, W)
				return FALSE
			else
				boutput(holder.owner, "That being's soul is not weakened enough. We need to curse it some more.")
				return TRUE

	proc/do_curse(var/mob/living/carbon/human/H, var/mob/living/intangible/wraith/W)
		var/cycles = 0
		var/active = TRUE
		while (active)
			if (!H?.bioHolder.GetEffect("death_curse"))
				boutput(W, "<span class='alert'>Those foolish mortals stopped your deadly curse before it claimed it's victim! You'll damn them all!</span>")
				active = FALSE
				return
			if (!isdead(H))
				hit_twitch(H)
				random_brute_damage(H, (cycles / 3))
				cycles ++
				if (prob(6))
					H.changeStatus("stunned", 2 SECONDS)
					boutput(H, "<span class='alert'><b>You feel netherworldly hands grasping at your soul!</b></span>")
				if (prob(4))
					boutput(H, "<span class='alert'>IT'S COMING FOR YOU!</span>")
					H.remove_stamina( rand(30, 70) )
				if ((cycles > 10) && prob(15))
					random_brute_damage(H, 1)
					playsound(H.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 70, 1)
					H.visible_message("<span class='alert'>[H]'s flesh tears open before your very eyes!!</span>")
					new /obj/decal/cleanable/blood/drip(get_turf(H))
			else
				var/turf/T = get_turf(H)
				var/datum/effects/system/bad_smoke_spread/S = new /datum/effects/system/bad_smoke_spread/(T)
				if (S)
					S.set_up(8, 0, T, null, "#000000")
					S.start()
				T.fluid_react_single("miasma", 60, airborne = 1)
				var/datum/abilityHolder/wraith/AH = W.abilityHolder
				H.gib()
				AH.regenRate += 2.0
				AH.corpsecount++
				active = FALSE
			sleep (1.5 SECONDS)
