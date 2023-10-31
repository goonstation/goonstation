/** There are many pitfalls in the game. Here is a list of them, for easier maintainence.
 * Oshan/nadir trench:	1 direct drop, 1 area
 * Polaris Pit:			2 landmarks
 * sea elevator shaft:	1 landmark
 * Icemoon:				2 landmarks
 * Biodome:				3 landmarks
 *
 *
 * These are ALL TURFS. They should STAY TURFS.
 * similar but not quite the same as /datum/component/teleport_on_enter
 *
 * Here is a note preserved from the initial commit, referring to the icemoon abyss pitfall
 * 	// this is the code for falling from abyss into ice caves
 *	// could maybe use an animation, or better text. perhaps a slide whistle ogg?
 **/

TYPEINFO(/datum/component/pitfall)
	initialization_args = list(
		ARG_INFO("BruteDamageMax", DATA_INPUT_NUM, "The maximum amount of random brute damage applied by the fall.", 0),
		ARG_INFO("TargetLandmark", DATA_INPUT_TEXT, "The landmark that the fall sends you to.", ""),
		ARG_INFO("TargetArea", DATA_INPUT_TYPE, "The area typepath that the target falls into. If null, then it drops onto the same coordinates.", null),
		ARG_INFO("TargetZ", DATA_INPUT_NUM, "The z level that the target falls into.", 5),
		ARG_INFO("LandingRange", DATA_INPUT_NUM, "If true, try to find a spot around the target to land on in range (x). Only for 'direct drops'.", 0),
		ARG_INFO("FallTime", DATA_INPUT_NUM, "How long it takes for a thing to fall into the pit.", 0.3 SECONDS)
	)

/// A component for turfs which make movable atoms "fall down a pit"
/datum/component/pitfall
	/// the maximum amount of brute damage applied. This is used in random_brute_damage()
	var/BruteDamageMax = 0
	/// The landmark that the fall sends you to. Is technically a string but you should use defines.
	var/TargetLandmark = ""
	/// The area path that the target falls into. If null, then it drops onto the same coordinates but on the target z level.
	var/TargetArea = null
	/// The z level that the target falls into if not via area or landmark.
	var/TargetZ = 5
	/// var/warptarget of the parent turf.
	var/turf/TargetTurf = null
	/// If true, try to find a spot around the target to land on in range(x). Only for direct drops i.e. if !TargetArea && !TargetLandmark
	var/LandingRange = 8
	/// How long it takes for a thing to fall into the pit. 0 is instant, but usually you'd have a couple deciseconds where something can be flung across. Should use time defines.
	var/FallTime = 0.3 SECONDS
	/// a list of targets for the fall to pick from
	var/list/TargetList = list()
	/// a list of turfs which if the atom is on when falltime is up, causes them to fall
	var/list/PitList = list(
		/turf/space/fluid/warp_z5,
		/turf/unsimulated/floor/polarispit,
		/turf/unsimulated/floor/setpieces/ancient_pit,
		/turf/simulated/floor/specialroom/sea_elevator_shaft,
		/turf/unsimulated/greek/pit,
		/turf/simulated/floor/arctic_elevator_shaft,
		/turf/unsimulated/floor/arctic/abyss,
		/turf/unsimulated/floor/lunar_shaft
	)
	/// the typecasted parent
	var/turf/typecasted_parent = null

// the arguments have a priority order. If TargetLandmark has a value, then TargetZ and TargetArea are ignored.
// If landmark and area are falsy, it does a 'direct drop' to similar coordinates, based on LandingRange.

/datum/component/pitfall/Initialize(BruteDamageMax = 50, TargetLandmark = "", TargetArea = null, TargetZ = 5, LandingRange = 8, FallTime = 0.3 SECONDS)
	if (!istype(src.parent, /turf))
		return COMPONENT_INCOMPATIBLE
	src.typecasted_parent = src.parent
	. = ..()
	src.BruteDamageMax	= BruteDamageMax
	src.TargetLandmark	= TargetLandmark
	src.TargetArea		= TargetArea
	src.TargetZ			= TargetZ
	src.TargetTurf		= src.typecasted_parent.warptarget
	src.LandingRange	= LandingRange
	src.FallTime		= FallTime
	RegisterSignal(src.parent, COMSIG_ATOM_ENTERED, PROC_REF(try_fall))
	RegisterSignal(src.parent, COMSIG_ATTACKBY, PROC_REF(update_targets))
	src.update_targets()

/datum/component/pitfall/proc/update_targets()
	if (src.TargetList && !length(src.TargetList) == 0)
		return	// no need to refresh the list
	if (src.TargetLandmark)
		return	// we use a separate mechanism, instead of a target list
	else if (src.TargetArea)
		for(var/turf/T in get_area_turfs(src.TargetArea))
			src.TargetList += T
	else
		// since oshan and nadir allow for digging up and down, this code is specific to those maps
		// so it checks for space fluid turfs as valid targets.
		for(var/turf/space/fluid/T in range(src.LandingRange, locate(src.typecasted_parent.x, src.typecasted_parent.y , src.TargetZ)))
			src.TargetList += T
			break
		// this part is for checking linked ladders downward.
		if(length(src.TargetList))
			var/needlink = TRUE
			var/turf/space/fluid/picked_turf = pick(src.TargetList)

			for(var/turf/space/fluid/T in range(5, picked_turf))
				if(T.linked_hole)
					needlink = FALSE
					break
			// if there is no existing connection, link up
			if(needlink)
				if(!picked_turf.linked_hole)
					picked_turf.linked_hole = src.typecasted_parent
					src.typecasted_parent.add_simple_light("trenchhole", list(120, 120, 120, 120))


/datum/component/pitfall/proc/try_fall(var/signalsender, var/atom/movable/AM)
	if (!istype(AM, /atom/movable) || istype(AM, /datum/projectile/))
		return
	if (HAS_FLAG(AM.event_handler_flags, IMMUNE_TRENCH_WARP))
		return
	if (AM.anchored || locate(/obj/lattice) in src.parent)
		return
	if (ismob(AM))
		var/mob/M = AM
		if (M.client?.flying || isobserver(AM) || isintangible(AM))
			return

	return_if_overlay_or_effect(AM)

	SPAWN(src.FallTime)
		if (src.FallTime)	// make sure they're still over pit when falltime elapses
			var/canfall = FALSE
			for (var/dummy in src.PitList)
				if (istype(AM.loc, dummy))
					canfall = TRUE
			if (!canfall)
				return

		if (istype(AM, /obj/machinery/vehicle))
			var/obj/machinery/vehicle/V = AM
			var/turf/target_turf = V.go_home()
			if (V.going_home && target_turf)
				V.going_home = 0
				AM.set_loc(target_turf)
				return

		if (src.TargetLandmark)
			typecasted_parent.fall_to(pick_landmark(src.TargetLandmark), AM, src.BruteDamageMax)
		else
			typecasted_parent.fall_to(pick(src.TargetList), AM, src.BruteDamageMax)
