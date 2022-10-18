//Look like someone else

/mob/living/critter/wraith/trickster_puppet
	name = "Trickster puppet"
	desc = "A strange shell of a person looking straight ahead with lifeless eyes."
	density = 1
	icon_state = "shade"
	speechverb_say = "says"
	speechverb_exclaim = "exclaims"
	speechverb_ask = "asks"
	var/const/life_tick_spacing = 20
	health_brute = 8
	health_brute_vuln = 1
	health_burn = 8
	health_burn_vuln = 1
	var/mob/wraith/wraith_trickster/master = null
	var/hauntBonus = 0
	var/last_life_update = 0
	var/traps_laid = 0

	New(var/turf/T, var/mob/wraith/wraith_trickster/M = null)
		..(T)
		if(M != null)
			src.master = M

		last_life_update = TIME

		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		src.abilityHolder = new /datum/abilityHolder/wraith(src)
		src.abilityHolder.points = master?.abilityHolder.points

		src.addAbility(/datum/targetable/wraithAbility/decay)
		src.addAbility(/datum/targetable/wraithAbility/command)
		src.addAbility(/datum/targetable/wraithAbility/animateObject)
		src.addAbility(/datum/targetable/wraithAbility/haunt)
		src.addAbility(/datum/targetable/wraithAbility/spook)
		src.addAbility(/datum/targetable/wraithAbility/whisper)
		src.addAbility(/datum/targetable/wraithAbility/blood_writing)
		src.addAbility(/datum/targetable/wraithAbility/mass_whisper)
		src.addAbility(/datum/targetable/wraithAbility/dread)
		src.addAbility(/datum/targetable/wraithAbility/hallucinate)
		src.addAbility(/datum/targetable/wraithAbility/fake_sound)
		src.addAbility(/datum/targetable/wraithAbility/lay_trap)

	Life(parent)
		..()
		var/life_time_passed = max(life_tick_spacing, TIME - last_life_update)

		src.hauntBonus = 0
		for (var/mob/living/carbon/human/H in viewers(6, src))
			if (!H.stat && !H.bioHolder.HasEffect("revenant"))
				src.hauntBonus += 6
				if(master != null)
					master.possession_points++

		if (master != null && master.next_area_change != null)
			if (master.next_area_change < TIME)
				master.next_area_change = TIME + 15 MINUTES
				master.get_new_booster_zones()

		if(hauntBonus > 0)
			src.abilityHolder.addBonus(src.hauntBonus * (life_time_passed / life_tick_spacing))


		src.abilityHolder.generatePoints(mult = (life_time_passed / life_tick_spacing))
		src.abilityHolder.updateText()

		last_life_update = TIME

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	death(var/gibbed)
		. = ..()
		qdel(src)

	disposing()
		if(master != null)
			src.master.set_loc(get_turf(src))
			master.abilityHolder.points = src.abilityHolder.points
			master.setStatus("corporeal", master.forced_haunt_duration)
			src.mind.transfer_to(master)
			var/datum/targetable/ability = master.abilityHolder.getAbility(/datum/targetable/wraithAbility/haunt)
			ability.doCooldown()
			src.master = null
		playsound(src, "sound/voice/wraith/wraithspook[pick("1","2")].ogg", 60, 0)
		. = ..()

	proc/demanifest()
		if(master != null)
			src.master.set_loc(get_turf(src))
			master.abilityHolder.points = src.abilityHolder.points
			src.mind.transfer_to(master)
			src.master = null
		qdel(src)
		return 0
