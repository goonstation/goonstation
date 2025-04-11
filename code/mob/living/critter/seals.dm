/*
 * Copyright (C) 2025 Bartimeus
 * Copyright (C) 2010,2016,2020-2025 Goonstation Contributors
 *
 * Contributed to the 35 Below Project, derived at least 32.2%
 * from code in Goonstation available through the terms of the
 * CreativeCommons BY-NC-SA 3.0 United States License ONLY.
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

ABSTRACT_TYPE(/mob/living/critter/small_animal/seal_arctic)
/mob/living/critter/small_animal/seal_arctic
	hand_count = 2
	random_name = FALSE
	butcherable = BUTCHER_YOU_MONSTER
	var/sealnoise = null

	New(loc)
		RegisterSignal(src, COMSIG_MOB_PULL_TRIGGER, PROC_REF(pull_reaction))
		. = ..()

	Move()
		if (prob(5) && src.sealnoise) // Want them to be noisy boys
			playsound(src, "sound/voice/animal/[sealnoise].ogg", 50, 10,10)
		..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "flipper"
		HH.limb_name = "flipper"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "mouth"
		HH.can_hold_items = FALSE

	on_pet(mob/user)
		if (..())
			return
		src.visible_message(SPAN_EMOTE("<b>[user]</b> [pick("hugs","pets","caresses","boops","squeezes")] [src]!"))
		if (prob(80))
			src.visible_message(SPAN_EMOTE("<b>[src]</b> [pick("coos","purrs","mewls","chirps","arfs","arps","urps")]."))
		else
			src.visible_message(SPAN_EMOTE("<b>[src]</b> hugs <b>[user]</b> back!"))
			if (user.reagents)
				user.reagents.add_reagent("hugs", 10)
			src.emote("coo")

	attackby(obj/item/W, mob/living/user)
		if (!src.ai?.enabled || is_incapacitated(src))
			return ..()
		if (istype(W, /obj/item/reagent_containers/food/snacks))
			var/obj/item/reagent_containers/food/snacks/snack = W
			if (findtext(W.name,"seal")) // for you, spacemarine9
				src.visible_message(SPAN_EMOTE("<b>[src]</b> [pick("groans","yelps")]!"))
				src.visible_message(SPAN_NOTICE("<b>[src]</b> gets frightened by [snack]!"))
				if (src.is_npc)
					src.ai.move_away(user, 10)
					SPAWN(1 SECOND) walk(src,0)
				return

			if (prob(5))
				src.visible_message(SPAN_NOTICE("<b>[src]</b> gives [snack] back to <b>[user]</b> as if they wanted to share!"))
				if (src.sealnoise)
					playsound(src, "sound/voice/animal/[sealnoise].ogg", 50, 10, 10)
				return

			snack.Eat(src, src)
			modify_christmas_cheer(1)
			src.HealDamage("all", 10, 10)
		else
			src.visible_message(SPAN_EMOTE("<b>[src]</b> [pick("groans","yelps")]!"))
			if (src.is_npc && istype(src, /mob/living/critter/small_animal/seal_arctic/baby))
				src.ai.move_away(user, 10)
			return ..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","coo")
				if (src.emote_check(voluntary, 50))
					if (src.sealnoise)
						playsound(src, "sound/voice/animal/[sealnoise].ogg", 60, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> coos!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","coo")
				return 2
		return ..()

	was_harmed(var/mob/M as mob, var/obj/item/weapon, var/special, var/intent)
		..()
		if (!isdead(src))
			src.call_help(M)

	death(var/gibbed)
		UnregisterSignal(src, COMSIG_MOB_PULL_TRIGGER)
		if (istype(src, /mob/living/critter/small_animal/seal_arctic/baby))
			modify_christmas_cheer(-20)
			src.desc = "The lifeless corpse of [src], why would anyone do such a thing?"
		if (gibbed)
			return ..()

		for (var/mob/living/critter/small_animal/seal_arctic/seal in view(7, src))
			if (!(is_incapacitated(seal) && seal.ai?.enabled))
				seal.visible_message(SPAN_EMOTE("<b>[seal]</b> [pick("groans","yelps")]!"))
				if (seal.is_npc)
					seal.ai?.move_away(src, 10)

		..()

	disposing()
		UnregisterSignal(src, COMSIG_MOB_PULL_TRIGGER)
		. = ..()

	proc/pull_reaction(source, mob/M)
		src.call_help(M)
		if ((is_incapacitated(src) || !src.ai?.enabled))
			return
		src.visible_message(SPAN_EMOTE("<b>[src]</b> [pick("groans","yelps")]!"))
		if (src.is_npc)
			src.ai?.move_away(src, 5)

	proc/call_help(mob/M)
		src.emote("scream")
		for (var/mob/living/critter/small_animal/seal_arctic/adult/adult_seal in view(7, src))
			if (is_incapacitated(adult_seal) || !adult_seal.ai?.enabled || adult_seal == src)
				continue
			var/datum/aiTask/task = adult_seal.ai.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(adult_seal.ai, adult_seal.ai.default_task))
			adult_seal.ai.priority_tasks += task
			adult_seal.ai.interrupt()
			adult_seal.ai.target = M

/mob/living/critter/small_animal/seal_arctic/baby
	name = "seal pup"
	real_name = "seal pup"
	desc = "A fluffy, innocent, adorable creature usually remaining close to it's parents. And to think those are hunted for blubber and fur..."
	icon_state = "seal"
	icon_state_dead = "seal-dead"
	speechverb_say = "trills"
	speechverb_exclaim = "barks"
	sealnoise = "sealegg"
	death_text = "%src% lets out a final weak coo and keels over."
	health_brute = 15
	health_burn = 15
	pet_text = list("gently baps", "pets", "cuddles")
	max_skins = 2
	ai_type = /datum/aiHolder/seal_baby

/mob/living/critter/small_animal/seal_arctic/adult
	name = "seal"
	real_name = "seal"
	desc = "This species seems to be well adapted to survive in regions that don't have access to large bodies of liquid water"
	death_text = "%src% lets out a final weak grumble and keels over."
	health_brute = 30
	health_brute_vuln = 0.5
	health_burn = 30
	health_burn_vuln = 0.5
	sealnoise = "sealgroan"
	icon_state = "sealadult"
	icon_state_dead = "sealadult-dead"
	max_skins = 4
	speechverb_say = "harrumphs"
	speechverb_exclaim = "roars"
	ai_type = /datum/aiHolder/seal_adult

/mob/living/critter/small_animal/seal_arctic/adult/matriarch
	name = "seal matriarch"
	real_name = "seal matriarch"
	desc = "This seal is quite a bit larger than the others. You can tell it lived longer than most seals you saw due to its flabby skin and scars."
	health_brute = 50
	health_brute_vuln = 0.4
	health_burn = 50
	health_burn_vuln = 0.4
	max_skins = 6

	ai_type = /datum/aiHolder/wanderer
