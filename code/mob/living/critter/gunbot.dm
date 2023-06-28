/mob/living/critter/robotic/gunbot
	name = "robot"
	real_name = "robot"
	desc = "A Security Robot, something seems a bit off."
	icon = 'icons/misc/critter.dmi'
	icon_state = "mars_sec_bot"
	custom_gib_handler = /proc/robogibs
	hand_count = 1
	can_throw = FALSE
	can_grab = FALSE
	can_disarm = FALSE
	health_brute = 20
	health_brute_vuln = 1
	health_burn = 20
	health_burn_vuln = 1
	speechverb_say = "states"
	speechverb_gasp = "states"
	speechverb_stammer = "states"
	speechverb_exclaim = "declares"
	speechverb_ask = "queries"

	ai_retaliates = FALSE
	ai_type = /datum/aiHolder/ranged
	faction = FACTION_DERELICT
	is_npc = TRUE

	var/eye_light_icon = "mars_sec_bot_eye"

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_THERMALVISION, src)
		var/image/eye_light = image(icon, "[eye_light_icon]")
		eye_light.plane = PLANE_SELFILLUM
		src.UpdateOverlays(eye_light, "eye_light")

	death(var/gibbed)
		..(gibbed = TRUE, do_drop_equipment = FALSE)

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
		HH.limb = new /datum/limb/gun/kinetic/arm38
		HH.name = ".38 Anti-Personnel Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand38"
		HH.limb_name = ".38 Anti-Personnel Arm"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE

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
		if (src.hand_range_attack(target))
			return TRUE

/mob/living/critter/robotic/gunbot/players
	hand_count = 3
	health_brute = 75
	health_burn = 50
	is_npc = FALSE

	get_melee_protection(zone, damage_type)
		return 6

	get_ranged_protection()
		return 2

/mob/living/critter/robotic/gunbot/syndicate
	name = "Syndicate robot"
	real_name = "Syndicate robot"
	desc = "A retrofitted Syndicate gunbot, it seems angry."
	icon = 'icons/misc/critter.dmi'
	icon_state = "mars_nuke_bot"
	eye_light_icon = "mars_nuke_bot_eye"

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
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears/intercom/syndicate(src)

	get_melee_protection(zone, damage_type)
		return 7

	get_ranged_protection()
		return 2.5

/mob/living/critter/robotic/gunbot/syndicate/polaris
	health_brute = 30
	health_burn = 30

	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 2
