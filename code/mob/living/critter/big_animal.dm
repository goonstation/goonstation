
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
	death_text = "%src% gives up the ghost!"
	hand_count = 2
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	butcherable = 1
	name_the_meat = TRUE
	max_skins = 3
	health_brute = 30
	health_brute_vuln = 0.6
	health_burn = 30
	health_burn_vuln = 0.8
	ai_retaliates = TRUE
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/lion
	is_npc = TRUE
	add_abilities = list(/datum/targetable/critter/slam, /datum/targetable/critter/bite/big)

	New()
		..()
		src.add_stam_mod_max("lion", 50)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_brute_vuln)

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
		HH.can_hold_items = FALSE

	critter_attack(var/mob/target)
		var/datum/targetable/critter/bite = src.abilityHolder.getAbility(/datum/targetable/critter/bite/big)
		var/datum/targetable/critter/slam = src.abilityHolder.getAbility(/datum/targetable/critter/slam)
		if (!bite.disabled && bite.cooldowncheck())
			bite.handleCast(target)
		if (!slam.disabled && slam.cooldowncheck() && prob(30))
			slam.handleCast(target)
		else
			if(prob(20))
				src.swap_hand()
			src.hand_attack(target)

	critter_scavenge(var/mob/target)
		src.visible_message("<span class='alert'<b>[src] bites a chunk out of [target]!</b></span>")
		playsound(src.loc, 'sound/items/eatfood.ogg', 20, 1)
		src.HealDamage("All", 4, 4)
		return ..()
