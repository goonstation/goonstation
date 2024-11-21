/obj/machinery/artifact/robot
	name = "automaton"
	associated_datum = /datum/artifact/robot

/datum/artifact/robot
	associated_object = /obj/machinery/artifact/robot
	type_name = "Automaton"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 200
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/language)
	validtypes = list("ancient")
	fault_blacklist = list(ITEM_ONLY_FAULTS,TOUCH_ONLY_FAULTS)
	activ_text = "whirs to life!"
	deact_text = "becomes eerily still."
	// possible AI types that the robot can have
	react_xray = list(50,20,90,8,"MECHANICAL")
	var/static/list/datum/aiHolder/possible_ais = list(/datum/aiHolder/artifact_wallplacer, /datum/aiHolder/artifact_wallsmasher, /datum/aiHolder/artifact_floorplacer, /datum/aiHolder/wanderer, /datum/aiHolder/aggressive)
	// possible floor types for the floor placing robots
	// possible wall types for the wall placing robots
	var/static/list/turf/floor_types = list(/turf/simulated/floor/industrial, /turf/simulated/floor/mauxite, /turf/simulated/floor/circuit/vintage, /turf/simulated/floor/glassblock/transparent, /turf/simulated/floor/void, /turf/simulated/floor/techfloor/yellow)
	var/static/list/turf/wall_types = list(/turf/simulated/wall/auto/supernorn/material/mauxite, /turf/simulated/wall/auto/reinforced/supernorn, /turf/simulated/wall/auto/supernorn)

	var/aiHolder_type
	var/floor_type
	var/wall_type

	New()
		.=..()
		aiHolder_type = pick(possible_ais)
		floor_type = pick(floor_types)
		wall_type = pick(wall_types)

	effect_activate(var/obj/O)
		. = ..()
		if(!istype(O.loc, /mob/living/critter/robotic/artifact))
			var/mob/living/critter/robotic/artifact/alive_form = new(O.loc, O, pick(possible_ais))
			O.set_loc(alive_form) //put the artifact inside the mob for convenience

	effect_deactivate(obj/O)
		var/mob/living/critter/robotic/artifact/alive_form = O.loc
		if(!istype(alive_form))
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
		.=..()
		parent_artifact = parent
		src.ai = new aitype(src)
		src.is_npc = TRUE
		src.appearance = parent.appearance
		src.name_tag = new()
		src.update_name_tag()
		animate_bumble(src)

	setup_healths()
		. = ..()
		add_hh_robot(health_brute, health_brute_vuln)
		add_hh_robot_burn(health_burn, health_burn_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/artifact
		HH.can_hold_items = FALSE

	death(var/gibbed)
		//don't care if we're gibbed, just drop the artifact and disable it
		parent_artifact.set_loc(src.loc)
		parent_artifact.ArtifactDeactivated()
		//and then get rid of the mob
		if(!gibbed)
			src.set_loc(null)
			qdel(src)
		.=..()

/datum/limb/artifact
	var/damtype = "brute"
	var/dmg_amount = 0
	var/stamina_dmg = 0
	var/hitsound

	New()
		.=..()
		//yummy copy-pasta
		src.damtype = pick("brute", "fire", "toxin")
		src.dmg_amount = rand(3,6)
		src.dmg_amount *= rand(1,5)
		if (prob(45))
			src.stamina_dmg = rand(50,120)
		src.hitsound = pick('sound/impact_sounds/Metal_Hit_Heavy_1.ogg','sound/impact_sounds/Wood_Hit_1.ogg','sound/effects/exlow.ogg','sound/effects/mag_magmisimpact.ogg','sound/impact_sounds/Energy_Hit_1.ogg',
		'sound/impact_sounds/Generic_Snap_1.ogg','sound/machines/mixer.ogg','sound/impact_sounds/Generic_Hit_Heavy_1.ogg','sound/weapons/ACgun2.ogg','sound/impact_sounds/Energy_Hit_3.ogg','sound/weapons/flashbang.ogg',
		'sound/weapons/grenade.ogg','sound/weapons/railgun.ogg')


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

		user.lastattacked = target
		ON_COOLDOWN(src, "limb_cooldown", 3 SECONDS)

// AI bits are in artifact_robot.dm

