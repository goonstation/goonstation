/mob/living/critter/gunbot
	name = "robot"
	real_name = "robot"
	desc = "A Security Robot, something seems a bit off."
	density = 1
	icon = 'icons/misc/critter.dmi'
	icon_state = "mars_sec_bot"
	custom_gib_handler = /proc/robogibs
	hand_count = 3
	can_throw = 0
	can_grab = 0
	can_disarm = 0
	blood_id = "oil"
	speechverb_say = "states"
	speechverb_gasp = "states"
	speechverb_stammer = "states"
	speechverb_exclaim = "declares"
	speechverb_ask = "queries"
	metabolizes = 0

	death(var/gibbed)
		..(gibbed, 0)
		if (!gibbed)
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)
			ghostize()
			qdel(src)
		else
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/screams/robot_scream.ogg" , 80, 1, channel=VOLUME_CHANNEL_EMOTE)
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
		HH.limb = new /datum/limb/gun/arm38
		HH.name = ".38 Anti-Personnel Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand38"
		HH.limb_name = ".38 Anti-Personnel Arm"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

		HH = hands[2]
		HH.limb = new /datum/limb/gun/abg
		HH.name = "ABG Riot Suppression Appendage"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handabg"
		HH.limb_name = "ABG Riot Suppression Appendage"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

		HH = hands[3]
		HH.limb = new /datum/limb/small_critter/strong
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "gunbothand"
		HH.limb_name = "gunbot hands"

	setup_healths()
		add_hh_robot(-75, 75, 1)
		add_hh_robot_burn(-50, 50, 1)

	get_melee_protection(zone, damage_type)
		return 6

	get_ranged_protection()
		return 2
