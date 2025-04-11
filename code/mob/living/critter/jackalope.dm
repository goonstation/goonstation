/*
 * Copyright (C) 2025 Bartimeus
 * Copyright (C) 2025 DisturbHerb
 * Copyright (C) 2010,2016,2020-2025 Goonstation Contributors
 *
 * Contributed to the 35 Below Project, derived at least 65.4%
 * from code in Goonstation available through the terms of the
 * CreativeCommons BY-NC-SA 3.0 United States License ONLY.
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/mob/living/critter/small_animal/jackalope
	name = "jackalope"
	real_name = "jackalope"
	desc = "A rabbit-like creature with two elongated antlers. Skittish and harmless, this animal has been rumored to exist for centuries."
	hand_count = 2
	icon_state = "jackalope"
	icon_state_dead = "jackalope_dead"
	speechverb_say = "squeals"
	speechverb_exclaim = "squeaks"
	speechverb_ask = "squeals"
	health_brute = 8
	health_burn = 8
	ai_type = /datum/aiHolder/wanderer
	is_npc = TRUE
	can_lie = FALSE
	var/attack_damage = 3

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/mouse_squeak.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> squeaks!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

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
