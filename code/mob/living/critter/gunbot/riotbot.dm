/mob/living/critter/robotic/gunbot/riotbot
	name = "Syndicate Suppression Unit"
	real_name = "Syndicate Suppression Unit"
	icon_state = "riotbot"
	base_icon_state = "riotbot"
	desc = "A sturdy version with a shield for increased survivability. Not nearly as lethal as the others though."
	health_brute = 15
	health_burn = 25
	health_burn_vuln = 0.5

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/shieldproto)

	seek_target(range)
		. = ..()

		if (length(.) && prob(10) && src.speak_lines)
			src.say(pick("HALT SLIMEBUCKET!", "SUPPRESSION IN PROGRESS.", "NANOTRASEN INTRUDER DETECTED.", "APPROACHING.", "HASTA LA VISTA BABY.", "TURN YOURSELF IN. IT IS NOT TOO LATE.", "RUB YOUR STOMACH AND PAT YOUR HEAD-- ERROR", "YOU CANNOT STOP ME."))

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/abg
		HH.name = "ABG Riot Suppression Appendage"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handabg"
		HH.limb_name = "ABG Riot Suppression Appendage"
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

	critter_ability_attack(mob/target)
		var/datum/targetable/werewolf/werewolf_defense = src.abilityHolder.getAbility(/datum/targetable/werewolf/werewolf_defense)
		if (!werewolf_defense.disabled && werewolf_defense.cooldowncheck())
			werewolf_defense.handleCast(target)
			return TRUE


	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 2

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears/intercom/syndicate(src)

/mob/living/critter/robotic/gunbot/riotbot/strong // Midrounds
	hand_count = 3
	health_brute = 75
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 1
	is_npc = FALSE

	setup_hands()
		. = ..()
		var/datum/handHolder/HH = hands[2]
		HH.limb = new /datum/limb/syndie_shield
		HH.name = "Mod. 81 Alcor Shield"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "shield"
		HH.limb_name = "Mod. 81 Alcor Shield"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE

		HH = hands[3]
		HH.limb = new /datum/limb/small_critter/strong
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "gunbothand"
		HH.limb_name = "gunbot hands"

/datum/targetable/critter/shieldproto
	name = "AP Shield"
	desc = "Knock assailants back then destroy incoming projectiles"
	icon_state = "robopush"
	cooldown = 10 SECONDS
	targeted = TRUE
	target_anything = TRUE

	var/datum/projectile/shieldpush/projectile = new

	cast(atom/target)
		. = ..()
		var/obj/projectile/P = initialize_projectile_pixel_spread(holder.owner, projectile, target )
		logTheThing(LOG_COMBAT, usr, "used their [src.name] ability at [log_loc(usr)]")
		if (P)
			P.mob_shooter = holder.owner
			P.launch()

/datum/projectile/shieldpush
	name = "AP Repulsion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "crescent_white"
	shot_sound = 'sound/weapons/pushrobo.ogg'
	damage = 10
	projectile_speed = 18

	on_hit(atom/hit, angle, var/obj/projectile/O)
		var/dir = get_dir(O.shooter, hit)
		var/pow = O.power
		if (isliving(hit))
			O.die()
			var/mob/living/mob = hit
			mob.do_disorient(stamina_damage = 20, knockdown = 0, stunned = 0, disorient = pow, remove_stamina_below_zero = 0)
			var/throw_type = mob.can_lie ? THROW_GUNIMPACT : THROW_NORMAL
			mob.throw_at(get_edge_target_turf(hit, dir), pow/2, 1, throw_type = throw_type)
			mob.emote("twitch_v")

	tick(obj/projectile/O)
		. = ..()
		for (var/obj/projectile/other in view(1, O))
			if (other != O)
				other.die()

/datum/limb/syndie_shield
	use_specials_on_all_intents = TRUE

	attack_range(atom/target, mob/user, params)
		src.harm_special.pixelaction(target, params, user)

	New(obj/item/parts/holder)
		. = ..()
		src.harm_special = new /datum/item_special/barrier/syndie
