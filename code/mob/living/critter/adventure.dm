////////////// Repair bots ////////////////
/mob/living/critter/robotic/repairbot
	name = "strange robot"
	real_name = "strange robot"
	desc = "It looks like some sort of floating repair bot or something?"
	icon_state = "ancient_repairbot"
	hand_count = 1
	can_throw = FALSE
	can_grab = FALSE
	can_disarm = FALSE
	health_brute = 10
	health_brute_vuln = 0.7
	health_burn = 10
	health_burn_vuln = 0.3
	use_stamina = FALSE
	ai_retaliates = TRUE
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
	ai_type = /datum/aiHolder/wanderer_aggressive
	is_npc = TRUE
	death_text = "%src% blows apart!"
	custom_gib_handler = /proc/robogibs
	say_language = "binary"
	voice_name = "synthesized voice"
	speechverb_say = "beeps"
	speechverb_gasp = "chirps"
	speechverb_stammer = "beeps"
	speechverb_exclaim = "beeps"
	speechverb_ask = "beeps"

	nice
		ai_type = /datum/aiHolder/wanderer

	understands_language(var/langname)
		if (langname == say_language || langname == "silicon" || langname == "binary" || langname == "english")
			return TRUE
		return FALSE

	New()
		..()
		src.name = "[pick("strange","weird","odd","bizarre","quirky","antique")] [pick("robot","automaton","machine","gizmo","thingmabob","doodad","widget")]"
		src.real_name = src.name

	process_language(var/message)
		var/datum/language/L = languages.language_cache[say_language]
		if (!L)
			L = languages.language_cache["english"]
		return L.get_messages(message, (1 - health / max_health) * 16)

	death(var/gibbed)
		elecflash(src, power = 3)
		..(gibbed, 0)
		ghostize()
		qdel(src)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/screams/robot_scream.ogg' , 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> screams!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears/intercom(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/arcflash
		HH.name = "Electric Intruder Countermeasure"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handzap"
		HH.limb_name = "Electric Intruder Countermeasure"
		HH.can_hold_items = FALSE
		HH.can_attack = FALSE
		HH.can_range_attack = TRUE

	setup_healths()
		add_hh_robot(src.health_brute, src.health_brute_vuln)
		add_hh_robot_burn(src.health_burn, src.health_burn_vuln)

	seek_target(var/range = 5)
		. = list()
		for (var/mob/living/C in hearers(range, src))
			if (isintangible(C)) continue
			if (isdead(C)) continue
			if (istype(C, /mob/living/critter/robotic/repairbot)) continue
			if (isrobot(C)) continue // Arcflash doesn't hurt borgs
			if (is_incapacitated(C)) continue // Intruder subdued do not chain stun them
			. += C

		if (length(.) && prob(15))
			playsound(src.loc,pick('sound/misc/ancientbot_beep1.ogg','sound/misc/ancientbot_beep2.ogg','sound/misc/ancientbot_beep3.ogg'), 50, 1)

	critter_attack(var/mob/target)
		if(prob(30))
			playsound(src.loc, pick('sound/misc/ancientbot_grump.ogg','sound/misc/ancientbot_grump2.ogg'), 50, 1)
		var/list/params = list()
		params["left"] = TRUE
		params["ai"] = TRUE
		src.hand_range_attack(target, params)

/mob/living/critter/robotic/repairbot/security
	name = "strange robot"
	real_name = "strange robot"
	desc = "A Security Robot, something seems a bit off."
	icon_state = "ancient_guardbot"
	health_brute = 15
	health_brute_vuln = 0.7
	health_burn = 15
	health_burn_vuln = 0.2

/mob/living/critter/robotic/repairbot/helldrone
	name = "weird machine"
	real_name = "strange robot"
	desc = "A machine, of some sort. It's probably off."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "drone_service_bot_off"
	health_brute = 20
	health_brute_vuln = 0.7
	health_burn = 20
	health_burn_vuln = 0.2
	var/activated = TRUE

	active
		src.wakeup()

	New()
		..()
		src.ai.disable()

	attackby(obj/item/W, mob/user)
		if (!activated)
			return
		return ..()

	proc/wakeup()
		if (src.activated)
			return
		src.ai.enable()
		src.activated = TRUE
		src.icon_state = "drone_service_bot"
		src.desc = "A machine. Of some sort. It looks mad"
		src.visible_message("<span class='combat'>[src] seems to power up!</span>")
