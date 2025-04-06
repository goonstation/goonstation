/*
 * Copyright (C) 2025 Bartimeus
 * Copyright (C) 2025 DisturbHerb
 * Copyright (C) 2010,2016,2020-2025 Goonstation Contributors
 *
 * Contributed to the 35 Below Project, derived at least 27.6%
 * from code in Goonstation available through the terms of the
 * CreativeCommons BY-NC-SA 3.0 United States License ONLY.
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/mob/living/critter/small_animal/goat
	name = "space goat"
	real_name = "space goat"
	desc = "A four-legged, mostly harmless type of goat. Known to frequently lick claretine deposits for sodium intake."
	hand_count = 2
	icon_state = "goat"
	icon_state_dead = "goat_dead"
	speechverb_say = "baas"
	speechverb_exclaim = "bleats"
	speechverb_ask = "baas"
	health_brute = 35
	health_burn = 35
	ai_type = /datum/aiHolder/goat
	is_npc = TRUE
	ai_retaliate_patience = 1 //they hardly need an excuse
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
	can_lie = FALSE
	var/attack_damage = 3
	var/shearing_cooldown = 3 MINUTES

	New()
		if(prob(50))	//sometimes they just crave violence
			ai_type = /datum/aiHolder/aggressive
		..()

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		//Baaaa
		if (src.is_npc && prob(5))
			src.emote("scream", 1)
		..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/goat.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> baas!")
		return null

	attackby(obj/item/I, mob/M)
		if (!issnippingtool(I))
			. = ..()
			return
		if (!ON_COOLDOWN(src, "shearing_cooldown", src.shearing_cooldown) && !isdead(src))
			M.visible_message(SPAN_NOTICE({"[M] gently shears off excess wool from [src]."}), \
								SPAN_NOTICE({"You gently shear off excess wool from [src]"}))
			new /obj/item/material_piece/cloth/wool/white(src.loc)
			return
		else
			boutput(M, SPAN_NOTICE({"[src] has been sheared recently."}))
			return

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/strong
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

	critter_basic_attack(mob/target)
		if (!ismob(target))
			return
		if (prob(20)) //A simple bite
			src.set_hand(2) //mouth
			src.set_a_intent(INTENT_HARM)
			src.hand_attack(target)
		else	//HEADBUTT
			if (prob(30))
				var/atom/source = get_turf(src)
				src.visible_message(SPAN_ALERT("[src] winds back a bit, then <B>barrels</B> towards [target], sending them flying!"))
				target.throw_at(get_edge_cheap(source, get_dir(src, target)),  3, 3)
			else if (prob(50))
				boutput(target, SPAN_ALERT("[src] knocks the wind right out of you!"))
				target.setStatus("paralysis", 3 SECONDS)
			else
				src.visible_message(SPAN_COMBAT("<B>[src]</B> headbutts [target]!"), SPAN_COMBAT("You headbutt [target]!"))
			playsound(src.loc, pick('sound/impact_sounds/Generic_Punch_5.ogg', 'sound/impact_sounds/Generic_Punch_4.ogg'), 50, 1, -1)
			random_brute_damage(target, rand(src.attack_damage, src.attack_damage+2))
		return TRUE

	can_critter_eat()
		src.active_hand = 2 // mouth hand
		src.set_a_intent(INTENT_HELP)
		return can_act(src,TRUE)

	//only aggressive goats will do this by default
	valid_target(mob/living/M)
		if ((!ishuman(M) && !issilicon(M)) || is_incapacitated(M))
			return FALSE
		if(GET_DIST(src, M) <= 6 && GET_DIST(src, M) >= 3)
			if(!ON_COOLDOWN(src, "goat_warning", 9 SECONDS)) //goats would like to avoid fighting you for territory if they can
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message(SPAN_ALERT("<B>[src]</B> stomps on the ground and stares at [M] in an intimidating stance!"))
				src.ai.priority_tasks += src.ai.get_instance(/datum/aiTask/timed/wait_in_ambush, list(src.ai, src.ai.default_task))
				src.ai.interrupt()
				src.set_dir(get_dir(src, M))
				if (prob(25))
					src.emote("scream", 1)
			return FALSE
		else if(GET_DIST(src, M) > 6) //you're far enough, human
			return FALSE
		return ..()
