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
	var/mob/living/intangible/wraith/wraith_trickster/master = null
	var/hauntBonus = 0
	var/last_life_update = 0
	var/traps_laid = 0
	var/datum/abilityHolder/wraith/AH = null

	faction = FACTION_WRAITH

	New(var/turf/T, var/mob/living/intangible/wraith/wraith_trickster/M = null, var/new_name = "Trickster puppet", var/new_real_name = "Trickster puppet")
		..(T)
		if(M != null)
			src.master = M

		last_life_update = TIME
		src.name = new_name
		src.real_name = new_real_name

		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		AH = src.add_ability_holder(/datum/abilityHolder/wraith)
		var/datum/abilityHolder/wraith/master_ability_holder = master.abilityHolder
		AH.points = master_ability_holder.points
		AH.possession_points = master_ability_holder.possession_points

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
					AH.possession_points++

		if (master != null && master.next_area_change != null)
			if (master.next_area_change < TIME)
				master.next_area_change = TIME + 15 MINUTES
				master.get_new_booster_zones()

		if(src.disposed)
			return

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
			var/datum/abilityHolder/wraith/master_ability_holder = master.abilityHolder
			master_ability_holder.points = AH.points
			master_ability_holder.possession_points = AH.possession_points
			master.setStatus("corporeal", master.forced_haunt_duration)
			src.mind.transfer_to(master)
			var/datum/targetable/ability = master_ability_holder.getAbility(/datum/targetable/wraithAbility/haunt)
			ability.doCooldown()
			src.master = null
		playsound(src, "sound/voice/wraith/wraithspook[pick("1","2")].ogg", 60, 0)
		. = ..()

	proc/demanifest()
		if(master != null)
			src.master.set_loc(get_turf(src))
			var/datum/abilityHolder/wraith/master_ability_holder = master.abilityHolder
			master_ability_holder.points = AH.points
			master_ability_holder.possession_points = AH.possession_points
			src.mind.transfer_to(master)
			src.master.Move(master.loc) //call Move manually so we do restricted Z checks
			src.master = null
		qdel(src)
		return 0
