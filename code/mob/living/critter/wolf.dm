/*
 * Copyright (C) 2025 Bartimeus
 * Copyright (C) 2025 DisturbHerb
 * Copyright (C) 2025 Firedhat
 * Copyright (C) 2025 TealSeer
 * Copyright (C) 2010,2016,2020-2025 Goonstation Contributors
 *
 * Contributed to the 35 Below Project, derived at least 35.4%
 * from code in Goonstation available through the terms of the
 * CreativeCommons BY-NC-SA 3.0 United States License ONLY.
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/mob/living/critter/small_animal/wolf
	name = "space wolf"
	real_name = "space wolf"
	desc = "A species of alien wolves with thicker than usual fur and an unquenchable bloodlust."
	hand_count = 2
	icon_state = "wolf"
	icon_state_dead = "wolf_dead"
	add_abilities = list(/datum/targetable/critter/pounce)
	speechverb_say = "barks"
	speechverb_exclaim = "howls"
	speechverb_ask = "yips"
	health_brute = 40
	health_burn = 40
	ai_type = /datum/aiHolder/wolf
	is_npc = TRUE
	ai_retaliate_patience = 1 //BARK BARK
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	can_lie = FALSE
	var/attack_damage = 8 //Bit low, but we are pack hunters
	var/is_hunting = FALSE //Did we just witness a howling?
	var/last_howl = 0 //When did the last howl happen?
	var/howl_cooldown = 20 SECONDS //How long between howls?

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.is_npc && prob(5))
			src.emote("scream", 1)

		//God please only one howl once in awhile
		if ((world.time >= (last_howl + howl_cooldown)) && is_hunting)
			is_hunting = FALSE
		..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/dogbark.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> barks!")
		return null

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
		HH.limb = new /datum/limb/mouth/wolf
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

	critter_basic_attack(mob/target)
		src.set_hand(2) //mouth
		..()

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/pounce/pounce = src.abilityHolder.getAbility(/datum/targetable/critter/pounce)
		if (!pounce.disabled && pounce.cooldowncheck() && prob(10))
			src.visible_message(SPAN_COMBAT("<B>[src]</B> pounces onto [target] and trips them!"), SPAN_COMBAT("You run into [target]!"))
			pounce.handleCast(target)
			return TRUE

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(20))
			src.visible_message(SPAN_ALERT("[src] snaps at [user] and bites [his_or_her(user)] hand!"), SPAN_ALERT("You snap at [user] and bite [his_or_her(user)] hand!!"))
			random_brute_damage(user, 5)
			user.emote("scream")
			playsound(src.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 70, 1)
			bleed(user, 5, 5)

	valid_target(mob/living/C)
		if (isintangible(C)) return FALSE
		if (isdead(C)) return FALSE
		if (istype(C, src.type)) return FALSE
		if (C in src.friends) return FALSE
		//We arent already hunting or biting someone? Howl
		if(!src.is_hunting && GET_DIST(src, C) > 2)
			playsound(src.loc, 'sound/voice/animal/werewolf_howl.ogg', 80, TRUE)
			var/count = 0
			src.is_hunting = TRUE
			src.last_howl = world.time
			src.visible_message(SPAN_ALERT("[src] starts howling and calls the pack!"), SPAN_ALERT("You call the pack! It's feasting time!"))
			//Find every other nearby non-hunting wolf
			for (var/mob/living/critter/small_animal/wolf/wolf in range(src, 8))
				if (wolf.is_hunting || wolf == src)
					continue
				var/datum/aiTask/wolf_task = wolf.ai.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(wolf.ai, wolf.ai.default_task))
				//Beefed up seek range, default is 7.
				wolf.is_hunting = TRUE
				wolf.last_howl = world.time
				wolf_task.max_dist = 17
				wolf_task.target = C
				wolf.ai.priority_tasks = list(wolf_task)
				wolf.ai.interrupt()
				count++
				if (count > 9) //Just in case we have infinite wolves or something
					break
			var/datum/aiTask/task = src.ai.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(src.ai, src.ai.default_task))
			task.max_dist = 17
			task.target = C
			src.ai.priority_tasks = list(task)
		return TRUE

	seek_target(range = 8)
		. = ..()


//special wolf mouth with other sounds and slightly lower damage
/datum/limb/mouth/wolf
	dam_low = 7
	dam_high = 11
	sound_attack = 'sound/impact_sounds/Flesh_Tear_2.ogg'
	stam_damage_mult = 0.5
	can_beat_up_robots = TRUE

	harm(mob/target, var/mob/user)
		if (!user || !target)
			return 0

		if (!target.melee_attack_test(user))
			return

		if (prob(src.miss_prob) || is_incapacitated(target)|| target.restrained())
			var/datum/attackResults/msgs = user.calculate_melee_attack(target, dam_low, dam_high, 0, stam_damage_mult, !isghostcritter(user), can_punch = 0, can_kick = 0)
			user.attack_effects(target, user.zone_sel?.selecting)
			msgs.base_attack_message = src.custom_msg ? src.custom_msg : "<b>[SPAN_COMBAT("[user] bites [target]!")]</b>"
			msgs.played_sound = src.sound_attack
			msgs.flush(0)
			user.HealDamage("All", 2, 0)
			if (prob(25))
				take_bleeding_damage(target, src, 25)
		else
			user.visible_message("<b>[SPAN_COMBAT("[user] attempts to bite [target] but misses!")]</b>")
		user.lastattacked = target
		ON_COOLDOWN(src, "limb_cooldown", COMBAT_CLICK_DELAY)
