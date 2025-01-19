/mob/living/critter/robotic/gunbot/medibot
	name = "Syndicate Medical Unit"
	real_name = "Syndicate Medical Unit"
	icon_state = "medibot"
	base_icon_state = "medibot"
	desc = "A medical unit, doesn't pose as much of a threat. Looks a little smaller than the other ones."
	health_brute = 12
	health_burn = 12
	health_burn_vuln = 0.9

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/robofast)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/syringe/gunbot
		HH.name = "Syringe Gun"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "syringegun"
		HH.limb_name = "Syringe Gun"

		HH = hands[2]
		HH.limb = new /datum/limb/claw
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handr"
		HH.name = "right arm"
		HH.limb_name = "mauler claws"


	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 2

	setup_equipment_slots()
		return

/mob/living/critter/robotic/gunbot/medibot/strong
	hand_count = 3
	health_brute = 50
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 1
	is_npc = FALSE

	setup_hands()
		. = ..()
		var/datum/handHolder/HH = hands[2]
		HH.limb = new /datum/limb/gun/kinetic/syringe/gunbot_heal
		HH.name = "Heal Syringe Gun"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "syringegun+"
		HH.limb_name = "Heal Syringe Gun"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE

		HH = hands[3]
		HH.limb = new /datum/limb/small_critter/strong
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "gunbothand"
		HH.limb_name = "gunbot hands"

/datum/projectile/syringefilled/gunbot
	name = "syringe"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "syringeproj"
	dissipation_rate = 1
	dissipation_delay = 7
	damage = 10
	hit_ground_chance = 10
	shot_sound = 'sound/weapons/medsmg.ogg'
	venom_id = list("formaldehyde", "atropine")
	inject_amount = 3.5

/datum/projectile/syringefilled/heal
	sname = "Healing Needle"
	name = "Healing Needle"
	shot_sound = 'sound/effects/syringeproj.ogg'
	venom_id = list("salicylic_acid", "saline")
	inject_amount = 7.5
	damage = 0
	cost = 3
	casing = /obj/item/casing/small

/datum/limb/gun/kinetic/syringe/gunbot
	proj = new /datum/projectile/syringefilled/gunbot
	shots = 4
	current_shots = 4
	cooldown = 2 SECONDS
	reload_time = 10 SECONDS

/datum/limb/gun/kinetic/syringe/gunbot_heal
	proj = new /datum/projectile/syringefilled/heal
	shots = 4
	current_shots = 4
	cooldown = 2 SECONDS
	reload_time = 10 SECONDS

/datum/targetable/critter/robofast
	name = "ER Speed Mode"
	desc = "Overcharge your cell to remove all stuns and speed yourself up."
	icon_state = "robospeed"
	cooldown = 30 SECONDS
	targeted = FALSE

	cast(atom/target)
		if (..())
			return TRUE
		holder.owner.delStatus("stunned")
		holder.owner.delStatus("knockdown")
		holder.owner.delStatus("paralysis")
		holder.owner.delStatus("slowed")
		holder.owner.delStatus("disorient")
		holder.owner.change_misstep_chance(-INFINITY)
		playsound(holder.owner, 'sound/machines/shielddown.ogg', 80, 1)
		holder.owner.setStatusMin("robospeed", 10 SECONDS)
		return FALSE
