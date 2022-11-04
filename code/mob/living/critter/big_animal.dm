
/mob/living/critter/lion
	name = "lion"
	real_name = "lion"
	desc = "Oh christ"
	density = 1
	custom_gib_handler = /proc/gibs
	icon_state = "lion"
	icon_state_dead = "lion-dead"
	speechverb_say = "growls"
	speechverb_exclaim = "roars"
	speechverb_ask = "meows"
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	butcherable = 1
	name_the_meat = 1
	max_skins = 1
	add_abilities = list(/datum/targetable/critter/slam,
						/datum/targetable/critter/bite/big)

	setup_healths()
		add_hh_flesh(20, 0.5)
		add_hh_flesh_burn(20, 0.5)
		add_health_holder(/datum/healthHolder/toxin)
		add_health_holder(/datum/healthHolder/brain)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/claw
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth			// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0
