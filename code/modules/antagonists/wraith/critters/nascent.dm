//Only used to morph into something else.
//Avoids the issue of the game crashing when chosen and the transform prompt being lost.

/mob/living/critter/wraith/nascent
	name = "???"
	real_name = "???"
	desc = "It looks unfinished"
	density = 1
	icon = 'icons/mob/mob.dmi'
	icon_state = "poltergeist-corp"
	hand_count = 0
	health_brute = 50
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 0.8
	var/mob/wraith/master = null
	var/deathsound = "sound/voice/wraith/revleave.ogg"

	New(var/turf/T, var/mob/wraith/M = null)
		..(T)
		if(M != null)
			src.master = M

			if (isnull(M.summons))
				M.summons = list()
			M.summons += src

		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		//Let us spawn as stuff
		abilityHolder.addAbility(/datum/targetable/critter/nascent/become_spiker)
		abilityHolder.addAbility(/datum/targetable/critter/nascent/become_voidhound)
		abilityHolder.addAbility(/datum/targetable/critter/nascent/become_commander)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)


	death(var/gibbed)
		if (!gibbed)
			playsound(src, src.deathsound, 50, 0)
			qdel(src)
		return ..()
