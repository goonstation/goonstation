ABSTRACT_TYPE(/mob/living/critter/vending)
/mob/living/critter/vending
	name = "snack machine"
	real_name = "snack machine"
	desc = "Tasty treats for crewman eats."
	icon = 'icons/obj/vending.dmi'
	icon_state = "snack"
	density = 1
	custom_gib_handler = /proc/robogibs
	hand_count = 2
	can_throw = 0
	can_grab = 0
	can_disarm = 0
	blood_id = "oil"
	speech_verb_say = "states"
	speech_verb_gasp = "states"
	speech_verb_stammer = "states"
	speech_verb_exclaim = "declares"
	speech_verb_ask = "queries"
	metabolizes = 0
	stepsound = 'sound/impact_sounds/Metal_Clang_3.ogg'
	var/limb_name = "snack dispenser"
	var/limb_type = /datum/limb/gun/spawner/snack_dispenser
	var/random = FALSE

	New()
		. = ..()
		AddComponent(/datum/component/waddling)

	death(var/gibbed)
		..(gibbed, 0)
		if (!gibbed)
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)
			ghostize()
			qdel(src)
		else
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), sound_scream , 80, 1)
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
		HH.limb = new src.limb_type
		HH.name = limb_name
		HH.limb_name = limb_name
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handzap"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "dispenser door"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0
		HH.can_attack = 1

	setup_healths()
		add_hh_robot(75, 1)
		add_hh_robot_burn(50, 1)

	get_melee_protection(zone, damage_type)
		return 6

	get_ranged_protection()
		return 2

/mob/living/critter/vending/snack
	name = "snack machine"
	real_name = "snack machine"
	desc = "Tasty treats for crewman eats."
	icon = 'icons/obj/vending.dmi'
	icon_state = "snack"
	limb_type = /datum/limb/gun/spawner/snack_dispenser
	limb_name = "snack dispenser"

/mob/living/critter/vending/ice_cream
	name = "Ice Cream Dispenser"
	real_name = "Ice Cream Dispenser"
	desc = "A machine designed to dispense space ice cream."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "ice_creamer0"
	limb_type = /datum/limb/gun/spawner/ice_cream_dispenser
	limb_name = "ice cream dispenser"

/mob/living/critter/vending/monkey_organ
	name = "ValuChimp"
	real_name = "ValuChimp"
	desc = "More fun than a barrel of monkeys! Monkeys may or may not be synthflesh replicas, may or may not contain partially-hydrogenated banana oil."
	icon_state = "monkey"
	limb_type = /datum/limb/gun/spawner/organ_dispenser
	limb_name = "\"monkey\" dispenser"

/mob/living/critter/vending/random
	random = TRUE

	New()
		var/type = pick(concrete_typesof(/mob/living/critter/vending) - /mob/living/critter/vending/random)
		var/mob/living/critter/vending/M = new type
		src.name = M.name
		src.real_name = M.real_name
		src.desc = M.desc
		src.icon = M.icon
		src.icon_state = M.icon_state
		src.limb_type = M.limb_type
		src.limb_name = M.limb_name
		. = ..()

/mob/living/critter/vending/smes
	name = "power storage unit"
	real_name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon = 'icons/obj/power.dmi'
	icon_state = "smes"
	limb_type = /datum/limb/arcflash
	limb_name = "arc flash"

	setup_hands()
		. = ..()
		var/datum/handHolder/HH = hands[1]
		var/datum/limb/arcflash/L = HH.limb
		L.wattage = 1500
