/mob/living/critter/gorilla
	name= "gorilla"
	desc= "Holy shit"
	hand_count = 2
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	health_brute = 100
	health_brute_vuln = 0.6
	health_burn = 100
	health_burn_vuln = 1.2
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/wanderer
	is_npc = TRUE
	no_stamina_stuns = TRUE
	add_abilities = list(/datum/targetable/critter/tackle)
	var/group_retaliate = TRUE // so gorillas defend each other

	New()
		..()
		src.name = pick_string_autokey("names/monkey.txt")
		src.real_name = src.name
		src.add_stam_mod_max("gorilla", 50) //gorillas don't give a shit about your stun meta
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST, "gorilla", 25)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX, "gorilla", 25)


	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/gorilla
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left gorilla arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/gorilla
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right gorilla arm"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	valid_target(mob/living/C)
		if (istype(C, /mob/living/critter/gorilla)) return FALSE // in the infinite expanse of space, gorillas live in harmony

	critter_basic_attack(mob/target)
		if (issilicon(target))
			fuck_up_silicons(target)
			return TRUE
		if(!ON_COOLDOWN(src, "gorilla_ook", 3 SECONDS))
			src.visible_message(SPAN_ALERT("<b>[src] screeches!</b>"))
			playsound(src.loc, 'sound/voice/screams/monkey_scream.ogg', 90, 1, pitch=0.3)
		else
			return ..()

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/tackle = src.abilityHolder.getAbility(/datum/targetable/critter/tackle)
		if (!tackle.disabled && tackle.cooldowncheck())
			tackle.handleCast(target)
			return TRUE

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/maneatersnarl.ogg', 60, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_ALERT("<b>[src] roars!</b>")
		return null

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null) //for group retaliation
		if (src.ai && group_retaliate)
			for (var/mob/living/critter/gorilla/ally in view(7, src))
				if (ally?.alive && ally.valid_target(M))
					ally.trigger_group_retaliate(M)
		..()

	proc/trigger_group_retaliate(var/mob/target) // gorillas together strong
		if (!src.ai_retaliates || !src.ai.enabled)
			return

		if (length(src.ai.priority_tasks) > 0)
			return
		var/datum/aiTask/sequence/goalbased/retaliate/task_instance = src.ai.get_instance(/datum/aiTask/sequence/goalbased/retaliate, list(src.ai, src.ai.default_task))
		task_instance.targetted_mob = target
		task_instance.start_time = TIME
		src.ai.priority_tasks += task_instance
		src.ai.interrupt()

	proc/fuck_up_silicons(var/mob/living/silicon/silicon) // taken from brullbar
		if (isrobot(silicon) && !ON_COOLDOWN(src, "gorilla_messup_cyborg", 30 SECONDS))
			var/mob/living/silicon/robot/cyborg = silicon
			if (cyborg.part_head.ropart_get_damage_percentage() >= 85)
				src.visible_message(SPAN_ALERT("<B>[src] grabs [cyborg.name]'s head and wrenches it right off!</B>"))
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 70, 1)
				cyborg.compborg_lose_limb(cyborg.part_head)
			else
				src.visible_message(SPAN_ALERT("<B>[src] pounds on [cyborg.name]'s head furiously!</B>"))
				playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1)
				cyborg.part_head.ropart_take_damage(rand(20,40),0)
		else
			src.visible_message(SPAN_ALERT("<B>[src] smashes [silicon] furiously!</B>"))
			playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1)
			random_brute_damage(silicon, 15, 0)


/mob/living/critter/gorilla/enraged // for admemes
	ai_type = /datum/aiHolder/aggressive

	seek_target(var/range = 9)
		. = ..()

		if (length(.) && prob(10))
			playsound(src.loc, 'sound/voice/screams/monkey_scream.ogg', 90, 1, pitch=0.3)
			src.visible_message(SPAN_ALERT("<B>[src]</B> roars!"))
