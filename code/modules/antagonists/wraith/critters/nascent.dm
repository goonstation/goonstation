//Only used to morph into something else.
//Avoids the issue of the game crashing when chosen and the transform prompt being lost.

TYPEINFO(/mob/living/critter/wraith)
	start_listen_inputs = list(LISTEN_INPUT_EARS, LISTEN_INPUT_WRAITHCHAT, LISTEN_INPUT_DEADCHAT)
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN, SPEECH_OUTPUT_EQUIPPED, SPEECH_OUTPUT_WRAITHCHAT_WRAITH_SUMMON, SPEECH_OUTPUT_DEADCHAT_WRAITH_SUMMON)

/mob/living/critter/wraith
	var/name_generator_path = /datum/wraith_name_generator/wraith_summon

/mob/living/critter/wraith/New()
	. = ..()

	if (src.name_generator_path)
		var/datum/wraith_name_generator/name_generator = global.get_singleton(src.name_generator_path)
		src.real_name = name_generator.generate_name()
		src.UpdateName()


/mob/living/critter/wraith/nascent
	name = "???"
	real_name = "???"
	desc = "It looks unfinished"
	density = 1
	icon = 'icons/mob/mob.dmi'
	icon_state = "poltergeist-corp"
	hand_count = 0
	nodamage = 1
	health_brute = 50
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 0.8
	name_generator_path = null
	var/mob/living/intangible/wraith/master = null
	var/deathsound = "sound/voice/wraith/revleave.ogg"

	faction = list(FACTION_WRAITH)

	New(var/turf/T, var/mob/living/intangible/wraith/M = null)
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

	attackby(var/obj/item/I, mob/user)
		boutput(user, "[I] seems to just pass through...")

	attack_hand(mob/user)
		boutput(user, "Your hand just seems to phase through...")

	death(var/gibbed)
		if (src.master)
			src.master.summons -= src
		src.master = null
		if (!gibbed)
			playsound(src, src.deathsound, 50, 0)
			qdel(src)
		return ..()
