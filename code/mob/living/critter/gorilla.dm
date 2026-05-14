TYPEINFO(/mob/living/critter/gorilla)
	start_listen_languages = list(LANGUAGE_MONKEY, LANGUAGE_ENGLISH)

/mob/living/critter/gorilla
	name= "gorilla"
	desc= "Holy shit"
	hand_count = 2
	icon_state = "gorilla"
	icon_state_dead = "gorilla_dead"
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	health_brute = 100
	health_brute_vuln = 0.6
	health_burn = 100
	health_burn_vuln = 1.4
	speech_verb_say = "chimpers"
	speech_verb_exclaim = "roars"
	speech_verb_ask = "ooks"
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/gorilla
	is_npc = TRUE
	no_stamina_stuns = TRUE
	add_abilities = list(/datum/targetable/critter/roar, /datum/targetable/wrestler/throw/gorilla_fling)
	var/enraged = FALSE // gorillas that are not already enraged and witness an ally being harmed will switch to aggressive AI

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
		if (istype(C, /mob/living/critter/gorilla)) return FALSE
		. = ..()// in the infinite expanse of space, gorillas live in harmony

	critter_basic_attack(mob/target)
		if(!ON_COOLDOWN(src, "gorilla_ook", 5 SECONDS))
			src.visible_message(SPAN_ALERT("<b>[src] screeches!</b>"))
			playsound(src.loc, 'sound/voice/screams/monkey_scream.ogg', 90, 1, pitch=0.3)
		else
			return ..()

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/roar = src.abilityHolder.getAbility(/datum/targetable/critter/roar)
		if (!roar.disabled && roar.cooldowncheck())
			roar.handleCast(target)
			return TRUE
		var/datum/targetable/wrestler/throw/gorilla_fling = src.abilityHolder.getAbility(/datum/targetable/wrestler/throw/gorilla_fling)
		if (!gorilla_fling.disabled && gorilla_fling.cooldowncheck() && is_incapacitated(target))
			//from pikaia behavior so gorillas can grab their target to use fling
			src.set_a_intent(INTENT_GRAB)
			src.set_dir(get_dir(src, target))

			var/list/params = list()
			params["ai"] = TRUE

			var/obj/item/grab/G = src.equipped()
			if (!istype(G)) //if it hasn't grabbed something, try to
				if(!isnull(G)) //if we somehow have something that isn't a grab in our hand
					src.drop_item()
					src.hand_attack(target, params)
				src.hand_attack(target, params)
			else
				if (G.affecting == null || G.assailant == null || G.disposed || isdead(G.affecting))
					src.drop_item()
					return

				if (G.state <= GRAB_PASSIVE)
					G.AttackSelf(src)
				else
					gorilla_fling.handleCast(target)
					src.set_a_intent(INTENT_HARM)
					return TRUE


	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/screams/monkey_scream.ogg', 90, 1, pitch=0.3, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_ALERT("<b>[src] screeches!</b>")
		return null

// special retaliate that sends all nearby gorillas to destroy the enemy
	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		for (var/mob/living/critter/gorilla/ally in view(7, src))
			if (ally == src) continue
			if (ally.ai)
				ally._ai_patience_count--
				ally.ai.was_harmed(weapon,M)
				if(ally.is_hibernating)
					if (ally.registered_area)
						ally.registered_area.wake_critters(M)
					else
						ally.wake_from_hibernation()
				if(!ally.enraged)
					ally.enraged = TRUE
					ally.gorilla_rage()

				// We were harmed, and our ai wants to fight back. Also we don't have anything else really important going on
				if (ally.ai_retaliates && ally.ai.enabled && length(ally.ai.priority_tasks) <= 0 && M != ally && ally.is_npc)
					var/datum/aiTask/sequence/goalbased/retaliate/task_instance = ally.ai.get_instance(/datum/aiTask/sequence/goalbased/retaliate, list(ally.ai, ally.ai.default_task))
					task_instance.targetted_mob = M
					task_instance.start_time = TIME
					ally.ai.priority_tasks += task_instance
					ally.ai.interrupt()

		if(!src.enraged)
			src.enraged = TRUE
			src.gorilla_rage()

		..()

	seek_target(var/range = 9)
		. = ..()

		if (length(.) && prob(10))
			playsound(src.loc, 'sound/voice/maneatersnarl.ogg', 60, 1)
			src.visible_message(SPAN_ALERT("<B>[src]</B> roars!"))



// perma switches the gorilla to a state of rage
	proc/gorilla_rage()
		qdel(src.ai)
		src.ai = null
		src.ai_type = /datum/aiHolder/gorilla_aggressive
		src.ai = new src.ai_type(src)


/mob/living/critter/gorilla/aggressive // gorrillas that start enraged for admemes
	ai_type = /datum/aiHolder/gorilla_aggressive
	desc = "HOLY SHIT"
	enraged = TRUE

/mob/living/critter/gorilla/carl
	desc = "Now with more molecules!"
	faction = list(FACTION_BOTANY)

	New()
		..()
		src.name = "Carl Jr."
		src.real_name = src.name
