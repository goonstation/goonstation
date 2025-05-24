/obj/machinery/artifact/robot
	name = "drone"
	associated_datum = /datum/artifact/robot

/datum/artifact/robot
	associated_object = /obj/machinery/artifact/robot
	type_name = "Drone"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 200
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/language)
	validtypes = list("ancient")
	fault_blacklist = list(ITEM_ONLY_FAULTS,TOUCH_ONLY_FAULTS)
	activ_text = "whirs to life!"
	deact_text = "becomes eerily still."
	react_xray = list(50,20,90,8,"MECHANICAL")
	combine_flags = ARTIFACT_DOES_NOT_COMBINE
	// possible AI types that the robot can have
	var/static/list/datum/aiHolder/possible_ais = list(/datum/aiHolder/artifact_wallplacer, /datum/aiHolder/artifact_wallsmasher, /datum/aiHolder/artifact_floorplacer, /datum/aiHolder/wanderer, /datum/aiHolder/aggressive, /datum/aiHolder/artifact_recycler)
	// possible floor types for the floor placing robots
	var/static/list/turf/floor_types = list(/turf/simulated/floor/industrial, /turf/simulated/floor/auto/glassblock/cyan, /turf/simulated/floor/circuit/vintage, /turf/simulated/floor/glassblock/transparent, /turf/simulated/floor/engine, /turf/simulated/floor/techfloor/yellow, /turf/simulated/floor/mauxite)
	// possible wall types for the wall placing robots
	var/static/list/turf/wall_types = list(/turf/simulated/wall/auto/supernorn/material/mauxite, /turf/simulated/wall/auto/reinforced/supernorn, /turf/simulated/wall/auto/supernorn)
	// possible item types for the recycler to create - /obj/item/path = cost. Cost is total item health of absorbed items
	var/static/list/item_types = list(
		/obj/item/bananapeel=1,
	 	/obj/item/fuel_pellet/cerenkite=25,
		/obj/item/balloon_animal/random=5,
		/obj/item/brick=10,
		/obj/item/chilly_orb=50, //weird, mysterious, useless
		/obj/item/mine/radiation/armed=100, //haha mean
		/obj/item/mine/stun/armed=80,
		/obj/item/nuclear_waste=50,
		/obj/item/old_grenade/light_gimmick=200,
		/obj/item/rubberduck=15, //quack
		/obj/item/seed/alien=100,
		/mob/living/critter/robotic/repairbot=100,
		/mob/living/critter/robotic/repairbot/security=120,
		/obj/item/artifact=200, //maybe too OP, so expensive
		/obj/machinery/bot/duckbot=100 //implies duckbots are ancient eldritch tech
		)

	var/aiHolder_type
	var/floor_type
	var/wall_type
	var/item_type
	var/item_cost
	//total health of absorbed items, for tracking recylcing
	var/absorbed_item_health = 0
	//artifact limb var storage
	var/limb_damtype = "brute"
	var/limb_dmg_amount = 0
	var/limb_stamina_dmg = 0
	var/limb_hitsound


	New()
		.=..()
		aiHolder_type = pick(possible_ais)
		floor_type = pick(floor_types)
		wall_type = pick(wall_types)
		item_type = pick(item_types)
		SPAWN(0) //the reason for this cursed spawn is that the artifact controller tries to init before the static lists are init'd
			item_cost = item_types[item_type]

		//this is copy pasted from the melee artifact New()
		limb_damtype = pick("brute", "fire", "toxin")
		limb_dmg_amount = rand(3,6)
		limb_dmg_amount *= rand(1,5)
		if (prob(45))
			limb_stamina_dmg = rand(50,120)
		limb_hitsound = pick('sound/impact_sounds/Metal_Hit_Heavy_1.ogg','sound/impact_sounds/Wood_Hit_1.ogg','sound/effects/exlow.ogg','sound/effects/mag_magmisimpact.ogg','sound/impact_sounds/Energy_Hit_1.ogg',
		'sound/impact_sounds/Generic_Snap_1.ogg','sound/machines/mixer.ogg','sound/impact_sounds/Generic_Hit_Heavy_1.ogg','sound/weapons/ACgun2.ogg','sound/impact_sounds/Energy_Hit_3.ogg','sound/weapons/flashbang.ogg',
		'sound/weapons/grenade.ogg','sound/weapons/railgun.ogg')

	effect_activate(var/obj/O)
		. = ..()
		if(!istype(O.loc, /mob/living/critter/robotic/artifact))
			var/mob/living/critter/robotic/artifact/alive_form = new(O.loc, O, aiHolder_type)
			O.transfer_stickers(alive_form)
			O.set_loc(alive_form) //put the artifact inside the mob for convenience

	effect_deactivate(obj/O)
		var/mob/living/critter/robotic/artifact/alive_form = O.loc
		if(istype(alive_form))
			alive_form.transfer_stickers(O)
			alive_form.gib()
		. = ..()

// Mob bits

/mob/living/critter/robotic/artifact
	name = "bizarre machine" //this should always be overridden by parent artifact appearance, but just in case
	var/obj/machinery/artifact/robot/parent_artifact
	can_throw = FALSE
	can_grab = FALSE
	can_disarm = FALSE
	hand_count = 1
	health_brute = 10
	health_brute_vuln = 0.5
	health_burn = 10
	health_burn_vuln = 0.2

	New(loc, var/obj/machinery/artifact/robot/parent, var/aitype)
		if(!istype(parent))
			throw EXCEPTION("Tried to create an artifact robot without a parent artifact!")
		if(!ispath(aitype))
			throw EXCEPTION("Tried to create an artifact robot without an ai type!")

		parent_artifact = parent
		.=..(loc)

		src.ai = new aitype(src)
		src.is_npc = TRUE
		src.appearance = parent.appearance
		src.name_tag = new()
		src.update_name_tag()

		//you cannot stun a machine
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST, "artifact_robot", 100)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX, "artifact_robot", 100)

		animate_bumble(src)


	setup_healths()
		. = ..()
		add_hh_robot(health_brute, health_brute_vuln)
		add_hh_robot_burn(health_burn, health_burn_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/artifact_robot_attack(null, parent_artifact.artifact)
		HH.can_hold_items = FALSE

	death(var/gibbed)
		//don't care if we're gibbed, just drop the artifact and disable it
		src.transfer_stickers(parent_artifact)
		parent_artifact.set_loc(src.loc)
		parent_artifact.ArtifactDeactivated()
		//and then get rid of the mob
		if(!gibbed)
			src.set_loc(null)
			qdel(src)
		.=..()

/datum/limb/artifact_robot_attack
	var/damtype = "brute"
	var/dmg_amount = 0
	var/stamina_dmg = 0
	var/hitsound

	New(var/obj/item/parts/holder, var/datum/artifact/robot/artifact_datum)
		.=..(holder)
		if(istype(artifact_datum))
			src.damtype = artifact_datum.limb_damtype
			src.dmg_amount = artifact_datum.limb_dmg_amount
			src.stamina_dmg = artifact_datum.limb_stamina_dmg
			src.hitsound = artifact_datum.limb_hitsound
		else
			throw EXCEPTION("This limb must be created with a robot artifact datum (/datum/artifact/robot)")

	help(mob/target, var/mob/living/user)
		harm(target, user)

	disarm(mob/target, var/mob/living/user)
		harm(target, user)

	grab(mob/target, var/mob/living/user)
		harm(target, user)

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if (!user || !target)
			return 0

		if (!target.melee_attack_test(user))
			return

		logTheThing(LOG_COMBAT, user, "attacks [constructTarget(target,"combat")] with an artifact limb at [log_loc(user)].")

		var/turf/T = get_turf(user)
		playsound(T, hitsound, 50, TRUE, -1)
		switch(damtype)
			if ("brute")
				random_brute_damage(target, dmg_amount,1)
			if ("fire")
				random_burn_damage(target, dmg_amount)
			if ("toxin")
				target.take_toxin_damage(rand(1, dmg_amount))
		if (src.stamina_dmg)
			target.do_disorient(stamina_damage = src.stamina_dmg, knockdown = src.stamina_dmg - 20, disorient = src.stamina_dmg - 40)

		var/action = pick("hit", "strike", "bonk")
		user.visible_message(SPAN_COMBAT("<b>[user] [action]s [target] with a strange club!</b>"))

		user.lastattacked = get_weakref(target)
		ON_COOLDOWN(src, "limb_cooldown", 3 SECONDS)

// AI bits are in artifact_robot.dm

