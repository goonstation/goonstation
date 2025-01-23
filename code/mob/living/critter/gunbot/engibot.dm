/mob/living/critter/robotic/gunbot/engineerbot
	name = "Syndicate MULTI Unit"
	real_name = "Syndicate MULTI Unit"
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

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/solder
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "welderhand"
		HH.name = "Soldering Iron"
		HH.limb_name = "soldering iron"

		HH = hands[2]
		HH.limb = new /datum/limb/solder
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand_martian"
		HH.name = "Soldering Iron"
		HH.limb_name = "soldering iron"

	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 2

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears/intercom/syndicate(src)

/mob/living/critter/robotic/gunbot/engineerbot/strong // Midrounds
	hand_count = 3
	health_brute = 75
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 1
	is_npc = FALSE

	New()
		. = ..()
		//the player controlled one gets a manual heal
		abilityHolder.removeAbility(/datum/targetable/critter/nano_repair)
		abilityHolder.addAbility(/datum/targetable/critter/repair_robot)

	setup_hands()
		. = ..()
		var/datum/handHolder/HH = hands[2]
		HH.limb = new /datum/limb/deconstructor
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand_martian"
		HH.name = "Deconstructor"
		HH.limb_name = "deconstructor"

		HH = hands[3]
		HH.limb = new /datum/limb/small_critter/strong
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "gunbothand"
		HH.limb_name = "gunbot hands"

/datum/limb/solder
	can_pickup_item = FALSE
	can_beat_up_robots = TRUE

	help(mob/target, var/mob/living/user)
		..()
		harm(target, user, 0)

	harm(mob/target, var/mob/living/user)
		if(check_target_immunity( target ))
			return FALSE

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 15, 15, 0, can_punch = FALSE, can_kick = FALSE)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = "burn"
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with [src.holder]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/generic_hit_2.ogg'
		msgs.damage_type = DAMAGE_BURN
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target
		attack_twitch(user)
		ON_COOLDOWN(src, "limb_cooldown", 3 SECONDS)

/datum/targetable/critter/nano_repair
	name = "nano-bot repair"
	desc = "Send out nano-bots to repair robotics in a 5 tile radius."
	icon_state = "roboheal"
	cooldown = 20 SECONDS
	targeted = FALSE

	cast(atom/target)
		if (..())
			return TRUE
		for (var/mob/living/robot in range(5, holder.owner))
			if (issilicon(robot) || istype(robot, /mob/living/critter/robotic))
				robot.HealDamage("all", 10, 10, 0)
		playsound(holder.owner, 'sound/items/welder.ogg', 80, 0)
		return FALSE

/datum/targetable/critter/repair_robot
	name = "Repair robot"
	desc = "Begin performing repairs on a robot."
	icon_state = "roboheal"
	targeted = TRUE
	cooldown = 2 SECONDS

	tryCast(atom/target, params)
		if (!(issilicon(target) || istype(target, /mob/living/critter/robotic)))
			boutput(holder.owner, SPAN_ALERT("You can't repair that!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		. = ..()

	cast(atom/target)
		. = ..()
		if (!actions.hasAction(holder.owner, "repair_robot"))
			actions.start(new /datum/action/bar/icon/repair_robot(holder.owner, target), holder.owner)

/datum/action/bar/icon/repair_robot
	id = "repair_robot"
	duration = 1 SECOND
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	icon = 'icons/effects/effects.dmi'
	icon_state = "gears"
	var/mob/living/user
	var/mob/living/target

	New(user, target)
		. = ..()
		src.user = user
		src.target = target

	onUpdate()
		..()
		if(BOUNDS_DIST(user, target) > 0 || user == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/sound = pick('sound/effects/elec_bzzz.ogg', 'sound/items/Welder.ogg', 'sound/items/mining_drill.ogg', 'sound/impact_sounds/Metal_Clang_1.ogg', 'sound/impact_sounds/Metal_Clang_3.ogg')
		user.set_dir(get_dir(user, target))
		attack_twitch(user)
		playsound(user.loc, sound, 50, TRUE)

	onStart()
		..()
		if(BOUNDS_DIST(user, target) > 0 || user == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		src.loopStart()

	onEnd()
		. = ..()
		target.HealDamage("All", 20, 20)
		if (target.health >= target.max_health)
			boutput(src.user, SPAN_NOTICE("[target] is fully healed"))
			return
		src.onRestart()


//Borrowing this, sorry Azrun!
/obj/item/salvager/gunbot
	name = "deconstructor"
	decon_time_mult = 0.5
	use_power(watts)
		return TRUE

/datum/limb/deconstructor
	can_pickup_item = FALSE
	var/obj/item/salvager/gunbot/tool = new

	attack_hand(atom/target, mob/user, reach, params, location, control)
		tool.set_loc(user)
		if (ismob(target))
			target.Attackby(src.tool, user, params)
		else
			tool.AfterAttack(target, user, reach, params)
