TYPEINFO(/mob/living/critter/robotic/gunbot)
	mats = list("metal_dense" = 12,
				"conductive_high" = 12,
				"dense" = 6)
/mob/living/critter/robotic/gunbot
	name = "robot"
	real_name = "robot"
	desc = "A Security Robot, something seems a bit off."
	icon = 'icons/mob/critter/robotic/gunbot.dmi'
	icon_state = "gunbot"
	var/base_icon_state = "gunbot"
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
	is_syndicate = TRUE

	ai_retaliates = FALSE
	ai_type = /datum/aiHolder/ranged
	faction = list(FACTION_DERELICT)
	is_npc = TRUE

	var/speak_lines = TRUE
	var/uses_eye_light = TRUE

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_THERMALVISION, src)
		if (src.uses_eye_light)
			var/image/eye_light = SafeGetOverlayImage("eye_light", 'icons/mob/critter/robotic/gunbot.dmi', "eye-[base_icon_state]")
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
					user.visible_message(SPAN_NOTICE("[user] gives [src] a [pick_string("descriptors.txt", "borg_pat")] pat on the [pick("back", "head", "shoulder")]."))
				if(INTENT_DISARM) //Shove
					playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, 1)
					user.visible_message(SPAN_ALERT("<B>[user] shoves [src]! [prob(40) ? pick_string("descriptors.txt", "jerks") : null]</B>"))
				if(INTENT_GRAB) //Shake
					if (istype(user, /mob/living/carbon/human/machoman))
						return ..()
					playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 30, 1, -2)
					user.visible_message(SPAN_ALERT("[user] shakes [src] [pick_string("descriptors.txt", "borg_shake")]!"))
				if(INTENT_HARM) //Dumbo
					if (istype(user, /mob/living/carbon/human/machoman))
						return ..()
					if (ishuman(user))
						if (user.is_hulk())
							src.TakeDamage("All", 5, 0)
							if (prob(20))
								var/turf/T = get_edge_target_turf(user, user.dir)
								if (isturf(T))
									src.visible_message(SPAN_ALERT("<B>[user] savagely punches [src], sending them flying!</B>"))
									src.throw_at(T, 10, 2)
								else
									src.visible_message(SPAN_ALERT("<B>[user] punches [src]!</B>"))
							playsound(src.loc, pick(sounds_punch), 50, 1, -1)
						else if (user.equipped_limb()?.can_beat_up_robots)
							user.equipped_limb().harm(src, user)
						else
							user.visible_message(SPAN_ALERT("<B>[user] punches [src]! What [pick_string("descriptors.txt", "borg_punch")]!"), SPAN_ALERT("<B>You punch [src]![prob(20) ? " Turns out they were made of metal!" : null] Ouch!</B>"))
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
		if (src.hand_attack(target, new/list("left" = TRUE)))
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

		src.visible_message(SPAN_SAY("[SPAN_NAME("[src]")] blares, \"<B>[processedMessage]</B>\""))

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
	icon_state = "nukebot"
	base_icon_state = "nukebot"
	hand_count = 3
	health_brute = 100
	health_brute_vuln = 1
	health_burn = 100
	health_burn_vuln = 1
	speak_lines = FALSE

	is_npc = FALSE
	faction = list(FACTION_SYNDICATE)

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
	desc = "Painted in red and black, all identifying marks have been scraped off. Darn."
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
	icon_state = "gunbot_light"
	hand_count = 2
	health_brute = 15
	health_brute_vuln = 1
	health_burn = 15
	health_burn_vuln = 1
	speak_lines = FALSE
	uses_eye_light = FALSE

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/smg
		HH.name = "9mm Anti-Personnel Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand38"
		HH.limb_name = "9mm Anti-Personnel Arm"


TYPEINFO(/mob/living/critter/robotic/gunbot/mrl)
	mats = list("metal_dense" = 16,
				"conductive_high" = 12,
				"dense_super" = 6,
				"energy" = 4)
/mob/living/critter/robotic/gunbot/mrl
	icon_state = "gunbot-base"
	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/mrl
		HH.name = "Fomalhaut MRL Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand38"
		HH.limb_name = "Fomalhaut MRL Arm"

		src.UpdateOverlays(image(src.icon,"gunbot-mrls"), "guns")

TYPEINFO(/mob/living/critter/robotic/gunbot/flame)
	mats = list("metal_dense" = 12,
				"conductive_high" = 12,
				"dense" = 6,
				"energy_high" = 4)
/mob/living/critter/robotic/gunbot/flame
	icon_state = "gunbot-base"
	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/fluid/flamethrower
		HH.name = "Vega flamethrower Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand38"
		HH.limb_name = "Vega flamethrower Arm"

		src.UpdateOverlays(image(src.icon, "gunbot-flamethrower"), "guns")

TYPEINFO(/mob/living/critter/robotic/gunbot/cannon)
	mats = list("metal_superdense" = 12,
				"conductive_high" = 12,
				"dense" = 6,
				"energy" = 4)
/mob/living/critter/robotic/gunbot/cannon
	icon_state = "gunbot-base"
	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/cannon
		HH.name = "Alphard 20mm cannon Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand38"
		HH.limb_name = "Alphard 20mm cannon Arm"

		src.UpdateOverlays(image(src.icon, "gunbot-cannon"), "guns")

/mob/living/critter/robotic/gunbot/striker
	icon_state = "gunbot-base"
	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/striker
		HH.name = "Striker-7 Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand38"
		HH.limb_name = "Striker-7 Arm"

		src.UpdateOverlays(image(src.icon, "gunbot-striker"), "guns")

TYPEINFO(/mob/living/critter/robotic/gunbot/minigun)
	mats = list("metal_dense" = 18,
				"conductive_high" = 12,
				"dense" = 6,
				"energy" = 4)
/mob/living/critter/robotic/gunbot/minigun
	icon_state = "gunbot-base"
	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/minigun

		HH.name = "Alpha Hydrae minigun Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand38"
		HH.limb_name = "Alpha Hydrae minigun Arm"

		src.UpdateOverlays(image(src.icon, "gunbot-heavy"), "guns")

TYPEINFO(/mob/living/critter/robotic/gunbot/chainsaw)
	mats = list("metal_superdense" = 12,
				"conductive_high" = 12,
				"dense" = 6,
				"energy" = 4)
/mob/living/critter/robotic/gunbot/chainsaw
	icon_state = "gunbot-base"
	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/item
		HH.item = new /obj/item/saw/syndie(src)
		HH.icon_state = "saw"
		HH.name = "red chainsaw Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb_name = "red chainsaw Arm"

		var/obj/item/saw/S = HH.item
		S.base_state = "blank"
		S.cant_drop = 1
		S.cant_self_remove = 1
		S.cant_other_remove = 1

		src.UpdateOverlays(image(src.icon, "gunbot-saw"), "guns")

	death(gibbed)
		var/datum/handHolder/HH = hands[1]
		qdel(HH.item)
		. = ..()

/obj/machinery/fabricator/gunbot
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "gunbot_fab"
	bound_width = 64
	bound_height = 32
	density = 1
	anchored = 1
	var/minimum_gunbots = 1
	var/building = FALSE
	var/progress = 0
	var/max_progress = 20

	New()
		src.AddComponent(/datum/component/obj_projectile_damage)
		. = ..()
		var/image/arms = SafeGetOverlayImage("arms", 'icons/obj/manufacturer.dmi', "gunbot_fab-arms")
		src.UpdateOverlays(arms, "arms")

		var/image/light = SafeGetOverlayImage("light", 'icons/obj/manufacturer.dmi', "gunbot_fab-lights", pixel_x=32)
		light.plane = PLANE_SELFILLUM
		src.UpdateOverlays(light, "light")

	update_icon()
		if(src.status & BROKEN)
			src.icon_state = "gunbot_fab-broken"
			src.ClearSpecificOverlays("arms", "light", "build")
		else if(progress)
			var/image/build = SafeGetOverlayImage("build", 'icons/mob/critter/robotic/gunbot.dmi', "bot-build-[clamp(round(src.progress/(src.max_progress/5)),1,4)]")
			src.UpdateOverlays(build, "build")

			var/image/arms = SafeGetOverlayImage("arms", 'icons/obj/manufacturer.dmi', "gunbot_fab-arms-m")
			src.UpdateOverlays(arms, "arms")

		if(!building)
			var/image/arms = SafeGetOverlayImage("arms", 'icons/obj/manufacturer.dmi', "gunbot_fab-arms")
			src.UpdateOverlays(arms, "arms")

			src.ClearSpecificOverlays("build")

	attackby(var/obj/item/I, var/mob/user)
		src.add_fingerprint(user)
		user.lastattacked = src
		changeHealth(-I.force)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		hit_twitch(src)
		..()

	onDestroy()
		src.status |= BROKEN
		src.UnsubscribeProcess()
		src.UpdateIcon()

	ex_act(severity)
		src.material_trigger_on_explosion(severity)
		switch(severity)
			if(1)
				changeHealth(-100)
				return
			if(2)
				changeHealth(-90)
				return
			if(3)
				changeHealth(-60)
				return

	process(var/mult)
		if(src.status & BROKEN)
			return

		if(src.building)
			src.progress++
			if(src.progress > src.max_progress)
				var/path = weighted_pick(list(/mob/living/critter/robotic/gunbot=50,
											  /mob/living/critter/robotic/gunbot/minigun=5,
											  /mob/living/critter/robotic/gunbot/flame=5,
											  /mob/living/critter/robotic/gunbot/striker=10,
											  /mob/living/critter/robotic/gunbot/cannon=2,
											  /mob/living/critter/robotic/gunbot/mrl=1
											))
				var/mob/G = new path(src)
				G.Move(get_step(src,SOUTH))

				progress = 0
				building = FALSE
			src.UpdateIcon()

		else
			var/area/A = get_area(src)
			var/count = 0
			for(var/mob/living/critter/robotic/gunbot/G in A)
				count++

			if(count < src.minimum_gunbots)
				building = TRUE

