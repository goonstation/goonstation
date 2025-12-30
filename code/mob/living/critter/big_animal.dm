/mob/living/critter/lion
	name = "lion"
	desc = "Oh christ"
	density = 1
	custom_gib_handler = /proc/gibs
	icon_state = "lion"
	icon_state_dead = "lion-dead"
	speech_verb_say = "growls"
	speech_verb_exclaim = "roars"
	speech_verb_ask = "meows"
	death_text = "%src% gives up the ghost!"
	hand_count = 2
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	butcherable = BUTCHER_ALLOWED
	name_the_meat = TRUE
	max_skins = 3
	health_brute = 20
	health_brute_vuln = 0.8
	health_burn = 20
	health_burn_vuln = 1
	ai_retaliates = TRUE
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/aggressive/scavenger
	is_npc = TRUE
	add_abilities = list(/datum/targetable/critter/bite/big)
	has_genes = TRUE

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

	critter_ability_attack(var/mob/target)
		var/datum/targetable/critter/bite = src.abilityHolder.getAbility(/datum/targetable/critter/bite/big)
		if (!bite.disabled && bite.cooldowncheck() && prob(40))
			bite.handleCast(target)
			return TRUE

	critter_basic_attack(mob/target)
		if(prob(20))
			src.swap_hand()
		return ..()

	critter_scavenge(var/mob/target)
		src.visible_message("<span class='alert'<b>[src] bites a chunk out of [target]!</b></span>")
		playsound(src.loc, 'sound/items/eatfood.ogg', 20, 1)
		src.HealDamage("All", 4, 4)
		return ..()

/mob/living/critter/lion/strong // Stronger one for admin stuff / one off spawns
	name = "alpha lion"
	desc = "Oh christ, this lion looks very buff..."
	health_brute = 40
	health_brute_vuln = 0.8
	health_burn = 40
	health_burn_vuln = 1
	add_abilities = list(/datum/targetable/critter/slam, /datum/targetable/critter/bite/big)
	is_npc = FALSE // Maybe change later if anyone wants to use these as a spawn

/mob/living/critter/void_scale
	name = "ominious scale"
	real_name = "void_scale"
	icon_state = "void_scale"
	icon_state_dead = "void_scale-dead"
	desc = "The sentient and very, very angry scale off a semi-eldritch leviathian. This would be invaluable to a geneticist."
	speech_verb_say = "echos"
	speech_verb_exclaim = "whirls"
	speech_verb_ask = "pings"
	death_text = "%src%, unable to suspend itself with eldritch energy falls to the floor!"
	hand_count = 1
	health_brute = 300
	health_brute_vuln = 0.6
	health_burn = 300
	health_burn_vuln = 1
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/ranged
	is_npc = TRUE
	butcherable = BUTCHER_ALLOWED
	meat_type = null
	skinresult = /obj/item/void_shield
	max_skins = 1

	add_abilities = list(/datum/targetable/critter/slam,
		/datum/targetable/wraithAbility/command/cultist,
		/datum/targetable/critter/psyblast,
		/datum/targetable/critter/teleport)
	has_genes = TRUE
	var/telerange = 7

	New()
		..()
		src.add_stam_mod_max("void_scale", 300)
		src.bioHolder.AddNewPoolEffect("plasma_metabolism", scramble=FALSE) // These are the intended loot for this path of the azone
		src.bioHolder.AddNewPoolEffect("hulk", scramble=FALSE)
		src.bioHolder.AddNewPoolEffect("ithillid", scramble=FALSE)
		src.bioHolder.AddNewPoolEffect("breathless", scramble=FALSE)
		src.bioHolder.AddNewPoolEffect("ghost_walk", scramble=FALSE)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_brute_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/energy/resonator			// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "retinal beam"						// designation of the hand - purely for show
		HH.limb_name = "eye"					// name for the dummy holder
		HH.can_hold_items = FALSE

	critter_ability_attack(var/mob/target)
		var/datum/targetable/critter/slam = src.abilityHolder.getAbility(/datum/targetable/critter/slam)
		var/datum/targetable/critter/telekinesis = src.abilityHolder.getAbility(/datum/targetable/wraithAbility/command/cultist)
		var/datum/targetable/critter/blast = src.abilityHolder.getAbility(/datum/targetable/critter/psyblast)
		var/datum/targetable/critter/teleport = src.abilityHolder.getAbility(/datum/targetable/critter/teleport)
		if (!slam.disabled && slam.cooldowncheck() && prob(40))
			slam.handleCast(target)
			return TRUE
		if (!telekinesis.disabled && telekinesis.cooldowncheck() && prob(10))
			telekinesis.handleCast(target.loc)
			return TRUE
		if (!blast.disabled && blast.cooldowncheck() && prob(50))
			blast.handleCast(target)
			. = TRUE
			if(!teleport.disabled && teleport.cooldowncheck())
				var/list/randomturfs = new/list()
				for(var/turf/T in orange(src, telerange))
					if(istype(T, /turf/space) || T.density)
						continue
					randomturfs.Add(T)
				teleport.handleCast(pick(randomturfs))

