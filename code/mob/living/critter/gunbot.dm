TYPEINFO(/mob/living/critter/robotic/gunbot)
	mats = 20

/mob/living/critter/robotic/gunbot
	name = "robot"
	real_name = "robot"
	desc = "A Security Robot, something seems a bit off."
	icon = 'icons/misc/critter.dmi'
	icon_state = "mars_sec_bot"
	custom_gib_handler = /proc/robogibs
	hand_count = 2
	can_throw = FALSE
	can_grab = FALSE
	can_disarm = FALSE
	health_brute = 20
	health_brute_vuln = 1
	health_burn = 20
	health_burn_vuln = 0.5
	speechverb_say = "states"
	speechverb_gasp = "states"
	speechverb_stammer = "states"
	speechverb_exclaim = "declares"
	speechverb_ask = "queries"

	ai_retaliates = FALSE
	ai_type = /datum/aiHolder/ranged
	faction = FACTION_DERELICT
	is_npc = TRUE

	var/speak_lines = TRUE
	var/eye_light_icon = "mars_sec_bot_eye"

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_THERMALVISION, src)
		var/image/eye_light = image(icon, "[eye_light_icon]")
		eye_light.plane = PLANE_SELFILLUM
		src.UpdateOverlays(eye_light, "eye_light")

	death(var/gibbed)
		if (!gibbed)
			src.gib()
		..(gibbed = TRUE, do_drop_equipment = FALSE)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/screams/robot_scream.ogg' , 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> screams!"
		return null

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears/intercom(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/arm38/fast
		HH.name = ".38 Anti-Personnel Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand38"
		HH.limb_name = ".38 Anti-Personnel Arm"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE

		HH = hands[2]
		HH.limb = new /datum/limb/small_critter/strong
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "gunbothand"
		HH.limb_name = "gunbot hands"

	setup_healths()
		add_hh_robot(src.health_brute, src.health_brute_vuln)
		add_hh_robot_burn(src.health_burn, src.health_burn_vuln)

	get_melee_protection(zone, damage_type)
		return 3

	get_ranged_protection()
		return 1.5

	get_disorient_protection()
		return max(..(), 80)

	get_disorient_protection_eye()
		return(50)

	attack_hand(mob/user)
		user.lastattacked = src
		if(!user.stat)
			if (user.a_intent != INTENT_HELP)
				actions.interrupt(src, INTERRUPT_ATTACKED)
			switch(user.a_intent)
				if(INTENT_HELP) //Friend person
					playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -2)
					user.visible_message("<span class='notice'>[user] gives [src] a [pick_string("descriptors.txt", "borg_pat")] pat on the [pick("back", "head", "shoulder")].</span>")
				if(INTENT_DISARM) //Shove
					playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, 1)
					user.visible_message("<span class='alert'><B>[user] shoves [src]! [prob(40) ? pick_string("descriptors.txt", "jerks") : null]</B></span>")
				if(INTENT_GRAB) //Shake
					if (istype(user, /mob/living/carbon/human/machoman))
						return ..()
					playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 30, 1, -2)
					user.visible_message("<span class='alert'>[user] shakes [src] [pick_string("descriptors.txt", "borg_shake")]!</span>")
				if(INTENT_HARM) //Dumbo
					if (istype(user, /mob/living/carbon/human/machoman))
						return ..()
					if (ishuman(user))
						if (user.is_hulk())
							src.TakeDamage("All", 5, 0)
							if (prob(20))
								var/turf/T = get_edge_target_turf(user, user.dir)
								if (isturf(T))
									src.visible_message("<span class='alert'><B>[user] savagely punches [src], sending them flying!</B></span>")
									src.throw_at(T, 10, 2)
								else
									src.visible_message("<span class='alert'><B>[user] punches [src]!</B></span>")
							playsound(src.loc, pick(sounds_punch), 50, 1, -1)
						else
							user.visible_message("<span class='alert'><B>[user] punches [src]! What [pick_string("descriptors.txt", "borg_punch")]!</span>", "<span class='alert'><B>You punch [src]![prob(20) ? " Turns out they were made of metal!" : null] Ouch!</B></span>")
							random_brute_damage(user, rand(2,5))
							playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 60, 1)
							if(prob(10)) user.show_text("Your hand hurts...", "red")
					else
						return ..()

	valid_target(mob/living/C)
		if (istype(C, /mob/living/critter/robotic/gunbot)) return FALSE
		if (is_incapacitated(C)) return FALSE //Bullets will probably miss
		return ..()

	critter_range_attack(var/mob/target)
		src.set_a_intent(INTENT_HARM)
		if (src.hand_attack(target))
			return TRUE

	seek_target(range)
		. = ..()

		if (length(.) && prob(10) && src.speak_lines)
			src.speak(pick("SECURITY OPERATION IN PROGRESS.","WARNING - YOU ARE IN A SECURITY ZONE.","ALERT - ALL OUTPOST PERSONNEL ARE TO MOVE TO A SAFE ZONE.","WARNING: THREAT RECOGNIZED AS NANOTRASEN, ESPONIAGE DETECTED","THIS IS FOR THE FREE MARKET","NANOTRASEN BETRAYED YOU."))

	proc/speak(var/message) // Come back and make this use say after speech rework is in
		var/fontSize = 2
		var/fontIncreasing = 1
		var/fontSizeMax = 2
		var/fontSizeMin = -2
		var/messageLen = length(message)
		var/processedMessage = ""

		for (var/i = 1, i <= messageLen, i++)
			processedMessage += "<font size=[fontSize]>[copytext(message, i, i+1)]</font>"
			if (fontIncreasing)
				fontSize = min(fontSize+1, fontSizeMax)
				if (fontSize >= fontSizeMax)
					fontIncreasing = 0
			else
				fontSize = max(fontSize-1, fontSizeMin)
				if (fontSize <= fontSizeMin)
					fontIncreasing = 1
			if(prob(10))
				processedMessage += pick("%","##A","-","- - -","ERROR")

		src.visible_message("<span class='game say'><span class='name'>[src]</span> blares, \"<B>[processedMessage]</B>\"")

		return

/mob/living/critter/robotic/gunbot/strong // Midrounds
	hand_count = 3
	health_brute = 75
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 1
	is_npc = FALSE

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/arm38

		HH = hands[2]
		HH.limb = new /datum/limb/gun/kinetic/abg
		HH.name = "ABG Riot Suppression Appendage"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handabg"
		HH.limb_name = "ABG Riot Suppression Appendage"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE

		HH = hands[3]
		HH.limb = new /datum/limb/small_critter/strong
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "gunbothand"
		HH.limb_name = "gunbot hands"

	get_melee_protection(zone, damage_type)
		return 6

	get_ranged_protection()
		return 2

/mob/living/critter/robotic/gunbot/syndicate
	name = "\improper Syndicate robot"
	real_name = "\improper Syndicate robot"
	desc = "A retrofitted Syndicate gunbot, it seems angry."
	icon = 'icons/misc/critter.dmi'
	icon_state = "mars_nuke_bot"
	eye_light_icon = "mars_nuke_bot_eye"
	hand_count = 3
	health_brute = 100
	health_brute_vuln = 1
	health_burn = 100
	health_burn_vuln = 1
	speak_lines = FALSE

	is_npc = FALSE
	faction = FACTION_SYNDICATE

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/rifle
		HH.name = "5.56 Rifle Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handrifle"
		HH.limb_name = "5.56 Rifle Arm"

		HH = hands[2]
		HH.limb = new /datum/limb/gun/kinetic/abg
		HH.name = "ABG Riot Suppression Appendage"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handabg"
		HH.limb_name = "ABG Riot Suppression Appendage"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE

		HH = hands[3]
		HH.limb = new /datum/limb/small_critter/strong
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "gunbothand"
		HH.limb_name = "gunbot hands"

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears/intercom/syndicate(src)

	get_melee_protection(zone, damage_type)
		return 7

	get_ranged_protection()
		return 2.5

/mob/living/critter/robotic/gunbot/syndicate/polaris
	name = "\improper unmarked robot"
	real_name = "\improper unmarked robot"
	desc = "Painted in red and black, all indentifying marks have been scraped off. Darn."
	health_brute = 20
	health_burn = 20
	is_npc = TRUE

	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 2

/mob/living/critter/robotic/gunbot/syndicate/polaris/ketchup
	interesting = "your scanner picks up a faint etching of a name. Even though your being shot at. Seems this one is named Ketchup."

/mob/living/critter/robotic/gunbot/syndicate/polaris/mustard
	interesting = "your scanner picks up a faint etching of a name. Even though your being shot at. Seems this one is named Mustard."

/mob/living/critter/robotic/gunbot/light
	icon = 'icons/mob/robots.dmi'
	icon_state = "syndibot"
	hand_count = 2
	health_brute = 15
	health_brute_vuln = 1
	health_burn = 15
	health_burn_vuln = 1
	speak_lines = FALSE

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/smg
		HH.name = "9mm Anti-Personnel Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand38"
		HH.limb_name = "9mm Anti-Personnel Arm"
