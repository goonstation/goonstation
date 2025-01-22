/mob/living/critter/robotic/gunbot/meleebot
	name = "Syndicate CQC Unit"
	real_name = "Syndicate CQC Unit"
	icon_state = "clawbot"
	base_icon_state = "clawbot"
	desc = "A security robot specially designed for close quarters combat. Prone to overheating.."
	health_brute = 20
	health_burn = 10
	health_burn_vuln = 0.7
	ai_type = /datum/aiHolder/aggressive
	stamina_regen = 20

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/hookshot)

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

	setStatus(statusId, duration, optional)
		if (statusId == "slowed")
			return
		. = ..()

/mob/living/critter/robotic/gunbot/meleebot/strong // Midrounds
	hand_count = 3
	health_brute = 75
	health_brute_vuln = 1
	health_burn = 75
	health_burn_vuln = 1
	is_npc = FALSE

	setup_hands()
		. = ..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/claw/gunbot
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handl"
		HH.name = "left arm"
		HH.limb_name = "mauler claws"

		HH = hands[2]
		HH.limb = new /datum/limb/claw/gunbot
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handr"
		HH.name = "right arm"
		HH.limb_name = "mauler claws"

		HH = hands[3]
		HH.limb = new /datum/limb/small_critter/strong
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "gunbothand"
		HH.limb_name = "gunbot hands"

/datum/limb/claw/gunbot
	damage = 20

/datum/targetable/critter/hookshot
	name = "GRABBER tech"
	desc = "Keep your friends close, and enemies closer."
	icon_state = "robograb"
	cooldown = 15 SECONDS
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		if (..())
			return TRUE

		var/obj/projectile/proj = initialize_projectile_pixel_spread(holder.owner, new/datum/projectile/special/robohook, get_turf(target))

		proj.special_data["owner"] = holder.owner
		proj.targets = list(target)

		proj.launch()

/datum/projectile/special/robohook
	name = "hook"
	dissipation_rate = 1
	dissipation_delay = 7
	icon_state = ""
	damage = 1
	hit_ground_chance = 100
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
				M.changeStatus("stunned", 5 SECONDS)
				M.visible_message("<span class='alert'>[M] gets grabbed by a hook and dragged!</span>")

		previous_line = drawLineObj(P.special_data["owner"], P, /obj/line_obj/tentacle ,'icons/obj/projectiles.dmi',"mid_gungrab",1,1,"start_gungrab","end_gungrab",OBJ_LAYER,1)
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
		if(get_turf(P) == P.orig_turf)
			return //don't draw a trail if we haven't moved
		if (previous_line != null)
			for (var/obj/O drawLineObjous_line)
				qdel(O)
		previous_line = DrawLine(P.special_data["owner"], P, /obj/line_obj/tentacle ,'icons/obj/projectiles.dmi',"mid_gungrab",1,1,"sstart_gungrab","end_gungrab",OBJ_LAYER,1)
