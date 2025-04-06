/*
 * Copyright (C) 2025 DisturbHerb
 * Copyright (C) 2025 Bartimeus
 * Copyright (C) 2010,2016,2020-2025 Goonstation Contributors
 *
 * Contributed to the 35 Below Project, derived at least 3.3%
 * from code in Goonstation available through the terms of the
 * CreativeCommons BY-NC-SA 3.0 United States License ONLY.
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/mob/living/critter/small_animal/llama
	name = "space llama"
	real_name = "space llama"
	desc = "A haughty-looking potato with legs."
	hand_count = 2
	icon_state = "llama"
	icon_state_dead = "llama_dead"
	speechverb_say = "hums"
	speechverb_exclaim = "snorts"
	speechverb_ask = "hums"
	health_brute = 50
	health_burn = 50
	ai_type = /datum/aiHolder/llama
	is_npc = TRUE
	ai_retaliate_patience = 1
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	can_lie = FALSE
	var/attack_damage = 5
	var/shearing_cooldown = 3 MINUTES

/mob/living/critter/small_animal/llama/New(loc)
	. = ..()
	abilityHolder.addAbility(/datum/targetable/critter/llamaspit)

// A lot of this is cargo culted from crater goats.
/mob/living/critter/small_animal/llama/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	//Baaaa
	if (src.is_npc && prob(5))
		src.emote("scream", 1)
	..()

/mob/living/critter/small_animal/llama/specific_emotes(act, param = null, voluntary = 0)
	switch (act)
		if ("scream")
			if (src.emote_check(voluntary, 50))
				// Yes, I know the sound is from an alpaca.
				playsound(src, 'sound/voice/animal/alpaca.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				return SPAN_EMOTE("<b>[src]</b> hums!")
	return null

/mob/living/critter/small_animal/llama/attackby(obj/item/I, mob/M)
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

/mob/living/critter/small_animal/llama/specific_emote_type(act)
	switch (act)
		if ("scream")
			return 2
	return ..()

/mob/living/critter/small_animal/llama/setup_hands()
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

/mob/living/critter/small_animal/llama/critter_basic_attack(mob/target)
	if (!ismob(target))
		return
	if (prob(50)) //A simple bite
		src.set_hand(2)
		src.set_a_intent(INTENT_HARM)
		src.hand_attack(target)
	else	//HEADBUTT
		if (prob(10))
			var/atom/source = get_turf(src)
			src.visible_message(SPAN_ALERT("[src] winds back a bit, then <B>barrels</B> towards [target], sending them flying!"))
			target.throw_at(get_edge_cheap(source, get_dir(src, target)),  3, 3)
		else if (prob(20))
			boutput(target, SPAN_ALERT("[src] knocks the wind right out of you!"))
			target.setStatus("paralysis", 3 SECONDS)
		else
			src.visible_message(SPAN_COMBAT("<B>[src]</B> headbutts [target]!"), SPAN_COMBAT("You headbutt [target]!"))
		playsound(src.loc, pick('sound/impact_sounds/Generic_Punch_5.ogg', 'sound/impact_sounds/Generic_Punch_4.ogg'), 50, 1, -1)
		random_brute_damage(target, rand(src.attack_damage, src.attack_damage+2))
	return TRUE

/mob/living/critter/small_animal/llama/can_critter_eat()
	src.active_hand = 2 // mouth hand
	src.set_a_intent(INTENT_HELP)
	return can_act(src, TRUE)

/mob/living/critter/small_animal/llama/valid_target(mob/living/M)
	if (!ishuman(M) && !issilicon(M))
		return FALSE
	return ..()

/mob/living/critter/small_animal/llama/proc/llamaspit(mob/M)
	var/datum/targetable/critter/llamaspit/ability = src.abilityHolder.getAbility(/datum/targetable/critter/llamaspit)
	if (!ability.disabled && ability.cooldowncheck())
		ability.handleCast(M)
		return TRUE

/datum/projectile/pie/llama
	name = "disgusting glob of spit"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "acidspit"
	stun = 0
