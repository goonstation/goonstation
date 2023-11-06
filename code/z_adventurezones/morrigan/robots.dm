//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Gunbot Critters ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/mob/living/critter/robotic/gunbot/morrigan/gunbot
	name = "Syndicate Sentinel Unit"
	real_name = "Syndicate Sentinel Unit"
	icon_state = "nukebot"
	base_icon_state = "nukebot"
	desc = "One of Morrigan's classic models... best avoid it."
	health_brute = 15
	health_burn = 15
	health_burn_vuln = 0.6
	is_npc = TRUE
	speak_lines = TRUE

	seek_target(range)
		. = ..()

		if (length(.) && prob(10) && src.speak_lines)
			src.say(pick("POTENTIAL INTRUDER. MOVING TO ELIMINATE.","YOU DO NOT BELONG HERE.","ALERT - ALL SYNDICATE PERSONNEL ARE TO MOVE TO A SAFE ZONE.","WARNING: THREAT RECOGNIZED AS NANOTRASEN.","Help!! Please I don- RESETTING.","YOU CANNOT ESCAPE. SURRENDER. NOW.","NANOTRASEN WILL LEAVE YOU BEHIND.","THIS IS NOT EVEN MY FINAL FORM."))
	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/morriganweak
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handl"
		HH.name = "left arm"
		HH.limb_name = "9mm Handgun"

	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 2

	setup_equipment_slots()
		return

/mob/living/critter/robotic/gunbot/morrigan/meleebot
	name = "Syndicate CQC Unit"
	real_name = "Syndicate CQC Unit"
	icon = 'icons/obj/adventurezones/Morrigan/critter.dmi'
	icon_state = "clawbot"
	base_icon_state = "clawbot"
	desc = "A security robot specially designed for close quarters combat. Prone to overheating.."
	health_brute = 20
	health_burn = 10
	health_burn_vuln = 0.7
	ai_type = /datum/aiHolder/aggressive

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/hookshot)

	seek_target(range)
		. = ..()

		if (length(.) && prob(10) && src.speak_lines)
			src.say(pick("GET. OVER. HERE.", "PREPARE TO BE TORN TO SHREDS.", "NANOTRASEN SCUM DETECTED.", "MOVING TO ENGAGE.", "THESE CLAWS DO NOT CARE ABOUT YOUR FEELINGS.", "SURRENDER OR BE DESTROYED.", "THIS ENDS BADLY FOR YOU.", "YOU DO NOT BELONG HERE."))

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/claw
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handl"
		HH.name = "left arm"
		HH.limb_name = "mauler claws"

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

/mob/living/critter/robotic/gunbot/morrigan/riotbot
	name = "Syndicate Suppression Unit"
	real_name = "Syndicate Suppression Unit"
	icon = 'icons/obj/adventurezones/Morrigan/critter.dmi'
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
		HH.limb = new /datum/limb/gun/kinetic/morriganabg
		HH.name = "ABG Riot Suppression Appendage"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handabg"
		HH.limb_name = "ABG Riot Suppression Appendage"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE

		HH = hands[2]
		HH.limb = new /datum/limb/gun/kinetic/morriganabg
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
		return

/mob/living/critter/robotic/gunbot/morrigan/engineerbot
	name = "Syndicate MULTI Unit"
	real_name = "Syndicate MULTI Unit"
	icon = 'icons/obj/adventurezones/Morrigan/critter.dmi'
	icon_state = "engineerbot"
	base_icon_state = "engineerbot"
	desc = "An engnieering unit, you can somehow feel that it's angry at you."
	health_brute = 20
	health_burn = 10
	health_burn_vuln = 0.8

	ai_type = /datum/aiHolder/aggressive

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/nano_repair)

	seek_target(range)
		. = ..()

		if (length(.) && prob(10) && src.speak_lines)
			src.say(pick("SMASH.", "THIS IS NOT WHERE YOU ARE SUPPOSED TO BE.", "NANOTRASEN TRESPASSING.", "YOUR PUNY FISTS CANNOT HURT ME.", "I WILL DECODE YOU.", "WHERE IS YOUR FIRE EXTINGUISHER.", "I HAVE PRESSED BOLTS HARDER THAN YOU.", "SHOULD HAVE NEVER COME HERE."))

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/transposed/morrigan
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "welderhand"
		HH.name = "Soldering Iron"
		HH.limb_name = "soldering iron"

		HH = hands[2]
		HH.limb = new /datum/limb/transposed/morrigan
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand_martian"
		HH.name = "Soldering Iron"
		HH.limb_name = "soldering iron"

	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 2

	setup_equipment_slots()
		return

/mob/living/critter/robotic/gunbot/morrigan/medibot
	name = "Syndicate Medical Unit"
	real_name = "Syndicate Medical Unit"
	icon = 'icons/obj/adventurezones/Morrigan/critter.dmi'
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

	seek_target(range)
		. = ..()

		if (length(.) && prob(10) && src.speak_lines)
			src.say(pick("YOU ARE NOT ON RECORDS.", "WAIT YOUR TURN.", "NANOTRASEN PATIENT DETECTED. CONFLICT.", "WAIT, I DON'T WANT TO HELP.", "THIS IS CONFUSING.", "YOU ARE NOT COVERED BY OUR HEALTH PLAN.", "I KNEW IT, I SHOULD'VE BEEN A SENTINEL UNIT", "LEAVE. NOW."))

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/syringe/morrigan
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

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Gunbot Midroll ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/mob/living/critter/robotic/gunbot/strong/medibot
	name = "Syndicate Medical Unit"
	real_name = "Syndicate Medical Unit"
	icon = 'icons/obj/adventurezones/Morrigan/critter.dmi'
	icon_state = "medibot"
	base_icon_state = "medibot"


	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/robofast)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/syringe/morrigan
		HH.name = "Syringe Gun"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "syringegun"
		HH.limb_name = "Syringe Gun"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE

		HH = hands[2]
		HH.limb = new /datum/limb/gun/kinetic/syringe/morriganmedheal
		HH.name = "Heal Syringe Gun"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "syringegun"
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

	get_melee_protection(zone, damage_type)
		return 6

	get_ranged_protection()
		return 2

/mob/living/critter/robotic/gunbot/strong/cqcunit
	name = "Syndicate CQC Unit"
	real_name = "Syndicate CQC Unit"
	icon = 'icons/obj/adventurezones/Morrigan/critter.dmi'
	icon_state = "clawbot"
	base_icon_state = "clawbot"
	desc = "A security robot specially designed for close quarters combat. Prone to overheating.."

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/hookshot)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/claw
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "sawflysaw"
		HH.name = "left arm"
		HH.limb_name = "mauler claws"

		HH = hands[2]
		HH.limb = new /datum/limb/gun/kinetic/morriganweak
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "hand380"
		HH.name = "9mm Handgun"
		HH.limb_name = "9mm Handgun"
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
		return 4

	get_ranged_protection()
		return 2

	setup_equipment_slots()
		return

/mob/living/critter/robotic/gunbot/strong/Riotbot
	name = "Syndicate Suppression Unit"
	real_name = "Syndicate Suppression Unit"
	icon = 'icons/obj/adventurezones/Morrigan/critter.dmi'
	icon_state = "riotbot"
	base_icon_state = "riotbot"
	health_brute = 75
	health_burn = 60

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/shieldproto)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/morriganabg
		HH.name = "ABG Riot Suppression Appendage"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handabg"
		HH.limb_name = "ABG Riot Suppression Appendage"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE

		HH = hands[2]
		HH.limb = new /datum/limb/gun/kinetic/morriganlethalabg
		HH.name = "ABG Riot Deletion Appendage"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handabg"
		HH.limb_name = "ABG Riot Deletion Appendage"
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
		return 5

	get_ranged_protection()
		return 3

	setup_equipment_slots()
		return

/mob/living/critter/robotic/gunbot/strong/engineerbot
	name = "Syndicate MULTI Unit"
	real_name = "Syndicate MULTI Unit"
	icon = 'icons/obj/adventurezones/Morrigan/critter.dmi'
	icon_state = "engineerbot"
	base_icon_state = "engineerbot"

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/nano_repair)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/transposed/morrigan
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "welderhand"
		HH.name = "Soldering Iron"
		HH.limb_name = "soldering iron"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE

		HH = hands[2]
		HH.limb = new /datum/limb/gun/energy/morriganmine
		HH.icon = 'icons/mob/critter_human.dmi'
		HH.icon_state = "handzap"
		HH.name = "left arm"
		HH.limb_name = "Mining Tool"
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
		return 4

	get_ranged_protection()
		return 2

	setup_equipment_slots()
		return


//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Gunbot Projectiles ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/datum/projectile/bullet/bullet_9mm/weak
	name = "bullet"
	damage = 22
	shot_sound = 'sound/weapons/smg_shot.ogg'
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_9mm
	casing = /obj/item/casing/small
	impact_image_state = "bhole-small"
	ricochets = TRUE

/datum/limb/gun/kinetic/morriganweak
	proj = new/datum/projectile/bullet/bullet_9mm/weak
	shots = 5
	current_shots = 5
	cooldown = 3 SECONDS
	reload_time = 10 SECONDS
	muzzle_flash = "muzzle_flash"

/datum/projectile/bullet/abg/morrigan
	name = "rubber slug"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	damage = 10
	stun = 0
	dissipation_rate = 3
	dissipation_delay = 4
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bhole"
	casing = /obj/item/casing/shotgun/blue

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power >= 16)
				var/throw_range = (proj.power > 20) ? 2 : 1

				var/turf/target = get_edge_target_turf(M, dirflag)
				M.throw_at(target, throw_range, 1, throw_type = THROW_GUNIMPACT)
				M.update_canmove()
			hit.changeStatus("staggered", clamp(proj.power/8, 5, 1) SECONDS)

		if(isliving(hit))
			var/mob/living/L = hit
			L.do_disorient(stamina_damage = 0, weakened = 0 SECOND, stunned = 0 SECOND, disorient = 7 SECONDS, remove_stamina_below_zero = 0)

/datum/projectile/syringefilled/morrigan
	name = "syringe"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "syringeproj"
	dissipation_rate = 1
	dissipation_delay = 7
	damage = 10
	hit_ground_chance = 10
	shot_sound = 'sound/effects/syringeproj.ogg'
	venom_id = list("formaldehyde", "atropine")
	inject_amount = 3.5

	on_hit(atom/hit, angle, var/obj/projectile/O)
		if (ismob(hit))
			if (hit.reagents)
				for (var/reagent_id as anything in venom_id)
					hit.reagents.add_reagent(reagent_id, inject_amount)

/datum/projectile/special/robohook
	name = "hook"
	dissipation_rate = 1
	dissipation_delay = 7
	icon_state = ""
	damage = 1
	hit_ground_chance = 0
	shot_sound = 'sound/impact_sounds/robograb.ogg'
	var/list/previous_line = list()

	on_hit(atom/hit, angle, var/obj/projectile/P)
		if (previous_line != null)
			for (var/obj/O in previous_line)
				qdel(O)
		if (ismob(hit))
			var/mob/M = hit
			if(hit == P.special_data["owner"]) return 1
			var/turf/destination = get_turf(P.special_data["owner"])
			if (destination)

				M.throw_at(destination, 10, 1)

				playsound(M, 'sound/impact_sounds/stabreel.ogg', 50, 0)
				M.TakeDamageAccountArmor("All", rand(3,4), 0, 0, DAMAGE_CUT)
				M.force_laydown_standup()
				M.changeStatus("paralysis", 5 SECONDS)
				M.visible_message("<span class='alert'>[M] gets grabbed by a hook and dragged!</span>")

		previous_line = DrawLine(P.special_data["owner"], P, /obj/line_obj/tentacle ,'icons/obj/projectiles.dmi',"mid_gungrab",1,1,"start_gungrab","end_gungrab",OBJ_LAYER,1)
		SPAWN(1 DECI SECOND)
			for (var/obj/O in previous_line)
				qdel(O)
		qdel(P)


	on_launch(var/obj/projectile/P)
		..()
		if (!("owner" in P.special_data))
			P.die()
			return

	on_end(var/obj/projectile/P)	//Clean up behind us
		SPAWN(1 DECI SECOND)
			for (var/obj/O in previous_line)
				qdel(O)
		..()

	tick(var/obj/projectile/P)	//Trail the projectile
		..()
		if (previous_line != null)
			for (var/obj/O in previous_line)
				qdel(O)
		previous_line = DrawLine(P.special_data["owner"], P, /obj/line_obj/tentacle ,'icons/obj/projectiles.dmi',"mid_gungrab",1,1,"sstart_gungrab","end_gungrab",OBJ_LAYER,1)

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Gunbot Limbs ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/datum/limb/gun/energy/morriganmine
	proj = new/datum/projectile/laser/mining/smgmine/gunbot
	shots = 4
	current_shots = 4
	cooldown = 2 SECONDS
	reload_time = 15 SECONDS
	muzzle_flash = "muzzle_flash_elec"

/datum/limb/gun/kinetic/morriganabg
	proj = new/datum/projectile/bullet/abg/morrigan
	shots = 6
	current_shots = 6
	cooldown = 3 SECONDS
	reload_time = 10 SECONDS
	muzzle_flash = "muzzle_flash"
/datum/limb/gun/kinetic/morriganlethalabg
	proj = new/datum/projectile/bullet/a12/weak/morrigan
	shots = 2
	current_shots = 2
	cooldown = 3 SECONDS
	reload_time = 15 SECONDS
	muzzle_flash = "muzzle_flash"
/datum/limb/gun/kinetic/syringe/morrigan
	proj = new/datum/projectile/syringefilled/morrigan
	shots = 4
	current_shots = 4
	cooldown = 2 SECONDS
	reload_time = 10 SECONDS
/datum/limb/gun/kinetic/syringe/morriganmedheal
	proj = new/datum/projectile/syringefilled/morrigan/medsmgheal
	shots = 4
	current_shots = 4
	cooldown = 2 SECONDS
	reload_time = 10 SECONDS

/datum/limb/transposed/morrigan
	help(mob/target, var/mob/living/user)
		..()
		harm(target, user, 0)

	harm(mob/target, var/mob/living/user)
		if(check_target_immunity( target ))
			return FALSE

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 15, 15, 0, can_punch = FALSE, can_kick = FALSE)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = "grab"
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with [src.holder]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/generic_hit_2.ogg'
		msgs.damage_type = DAMAGE_BURN
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target
		ON_COOLDOWN(src, "limb_cooldown", 3 SECONDS)

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Gunbot Abilities ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/datum/targetable/critter/hookshot
	name = "GRABBER tech"
	desc = "Keep your friends close, and enemies closer."
	icon_state = "robograb"
	cooldown = 15 SECONDS
	targeted = TRUE

	cast(atom/target)
		if (..())
			return TRUE

		var/obj/projectile/proj = initialize_projectile_pixel_spread(holder.owner, new/datum/projectile/special/robohook, get_turf(target))
		while (!proj || proj.disposed)
			proj = initialize_projectile_pixel_spread(holder.owner, new/datum/projectile/special/robohook, get_turf(target))

		proj.special_data["owner"] = holder.owner
		proj.targets = list(target)

		proj.launch()

/datum/targetable/critter/shieldproto
	name = "AP Shield"
	desc = "Knock assailants back then destroy incoming projectiles"
	icon_state = "robopush"
	cooldown = 10 SECONDS
	targeted = TRUE
	target_anything = TRUE

	var/datum/projectile/shieldpush/projectile = new

	cast(atom/target)
		var/obj/projectile/P = initialize_projectile_pixel_spread(holder.owner, projectile, target )
		logTheThing(LOG_COMBAT, usr, "used their [src.name] ability at [log_loc(usr)]")
		if (P)
			P.mob_shooter = holder.owner
			P.launch()

/datum/targetable/critter/nano_repair
	name = "nano-bot repair"
	desc = "Send out nano-bots to repair robotics in a 5 tile radius."
	icon_state = "roboheal"
	cooldown = 20 SECONDS
	targeted = FALSE

	cast(atom/target)
		if (..())
			return TRUE
		for (var/mob/living/critter/robotic/robot in range(5, holder.owner))
			robot.HealDamage("all", 10, 10, 0)
		playsound(holder.owner, 'sound/items/welder.ogg', 80, 0)
		return FALSE

/datum/targetable/critter/robofast
	name = "ER Speed Mode"
	desc = "Overcharge your cell to speed yourself up."
	icon_state = "robospeed"
	cooldown = 45 SECONDS
	targeted = FALSE

	cast(atom/target)
		if (..())
			return TRUE
		holder.owner.delStatus("stunned")
		holder.owner.delStatus("weakened")
		holder.owner.delStatus("paralysis")
		holder.owner.delStatus("slowed")
		holder.owner.delStatus("disorient")
		holder.owner.change_misstep_chance(-INFINITY)
		playsound(holder.owner, 'sound/machines/shielddown.ogg', 80, 1)
		holder.owner.setStatusMin("robospeed", 10 SECONDS)
		return FALSE
