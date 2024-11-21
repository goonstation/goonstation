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
	var/static/list/datum/aiHolder/possible_ais = list(/datum/aiHolder/artifact_wallplacer, /datum/aiHolder/artifact_wallsmasher, /datum/aiHolder/artifact_floorplacer, /datum/aiHolder/wanderer)
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
	health_brute = 50
	health_brute_vuln = 0.45
	health_burn = 50
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

	death(var/gibbed)
		//don't care if we're gibbed, just drop the artifact and disable it
		parent_artifact.set_loc(src.loc)
		parent_artifact.ArtifactDeactivated()
		//and then get rid of the mob
		if(!gibbed)
			src.set_loc(null)
			qdel(src)
		.=..()

// AI bits are in artifact_robot.dm

