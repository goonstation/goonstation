
TYPEINFO(/mob/living/critter/wraith/demon_doll)
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN, SPEECH_OUTPUT_EQUIPPED, SPEECH_OUTPUT_WRAITHCHAT_DEMON_DOLL)

/mob/living/critter/wraith/demon_doll
	name = "demon doll"
	desc = "It kind of hurts to look at, let alone hear."
	density = 1
	icon = 'icons/mob/wraith_critters.dmi'
	icon_state = "demon_doll"
	icon_state_dead = "dead_demon_doll"
	hand_count = 2
	health_brute = 50
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 0.8
	faction = list(FACTION_WRAITH)
	name_generator_path = /datum/wraith_name_generator/wraith_summon/doll
	var/mob/living/intangible/wraith/master = null

	New(var/turf/T, var/mob/living/intangible/wraith/M = null)
		..(T)
		if(M != null)
			src.master = M

			if (isnull(M.summons))
				M.summons = list()
			M.summons += src
		animate_shake(src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

	death(var/gibbed)
		if (src.master)
			src.master.summons -= src
		src.master = null
		playsound(src, "sound/voice/wraith/revleave.ogg", 50)
		if (gibbed)
			return ..()

		animate(src, 3 SECONDS, pixel_y = 40)
		SPAWN(3 SECONDS)
			src.gib()
		return ..()
