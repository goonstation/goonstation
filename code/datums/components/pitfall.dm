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

ABSTRACT_TYPE(/datum/component/pitfall)
/// A component for turfs which make movable atoms "fall down a pit"
/datum/component/pitfall
	/// a list of targets for the fall to pick from
	var/list/TargetList = list()
	/// the maximum amount of brute damage applied. This is used in random_brute_damage()
	var/BruteDamageMax = 0
	/// How long it takes for a thing to fall into the pit. 0 is instant, but usually you'd have a couple deciseconds where something can be flung across. Should use time defines.
	var/FallTime = 0.3 SECONDS

	// --------------- landmark targeting
	/// The landmark that the fall sends you to. Should be a landmark define.
	var/TargetLandmark = ""

	// --------------- area targeting
	/// The area path that the target falls into. For area targeting
	var/TargetArea = null

	// --------------- coordinate targeting
	/// The z level that the target falls into if not via area or landmark.
	var/TargetZ = 5
	/// If truthy, try to find a spot around the target to land on in range(x).
	var/LandingRange = 8


/datum/component/pitfall/Initialize(BruteDamageMax = 50, FallTime = 0.3 SECONDS)
	. = ..()
	if (!istype(src.parent, /turf))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(src.parent, COMSIG_ATOM_ENTERED, PROC_REF(start_fall))
	RegisterSignal(src.parent, COMSIG_ATTACKBY, PROC_REF(update_targets))
	src.BruteDamageMax	= BruteDamageMax
	src.FallTime		= FallTime
	src.update_targets()


/// returns the .parent but typecasted as a turf
/datum/component/pitfall/proc/typecasted_parent()
	RETURN_TYPE(/turf)
	. = src.parent

/// updates targets for area/coordinate targeting. is overridden added to in child types.
/datum/component/pitfall/proc/update_targets()
	return

/// called when movable atom AM enters a pitfall turf.
/datum/component/pitfall/proc/start_fall(var/signalsender, var/atom/movable/AM)
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

	if (src.FallTime)
		SPAWN(src.FallTime)
			AM.loc.GetComponent(/datum/component/pitfall)?.try_fall(signalsender, AM)
	else
		src.try_fall(signalsender, AM)

/// called when it's time for movable atom AM to actually fall into the pit
/datum/component/pitfall/proc/try_fall(var/signalsender, var/atom/movable/AM)
	if (istype(AM, /obj/machinery/vehicle))
		var/obj/machinery/vehicle/V = AM
		var/turf/target_turf = V.go_home()
		if (V.going_home && target_turf)
			V.going_home = 0
			AM.set_loc(target_turf)
			return

	if (!src.TargetList || !length(src.TargetList))
		src.update_targets()

	if (!src.TargetLandmark)
		src.fall_to(pick(src.TargetList), AM, src.BruteDamageMax)

/// a proc that makes a movable atom 'A' fall from 'src.typecasted_parent()' to 'T' with a maximum of 'brutedamage' brute damage
/datum/component/pitfall/proc/fall_to(var/turf/T, var/atom/movable/A, var/brutedamage = 50)
	if(istype(A, /obj/overlay) || A.anchored == 2)
		return
	#ifdef CHECK_MORE_RUNTIMES
	if(current_state <= GAME_STATE_WORLD_NEW)
		CRASH("[identify_object(A)] fell into [src.typecasted_parent()] at [src.typecasted_parent().x],[src.typecasted_parent().y],[src.typecasted_parent().z] ([src.typecasted_parent().loc] [src.typecasted_parent().loc.type]) during world initialization")
	#endif
	if (isturf(T))
		src.typecasted_parent().visible_message("<span class='alert'>[A] falls into [src.typecasted_parent()]!</span>")
		if (ismob(A))
			var/mob/M = A
			random_brute_damage(M, brutedamage)
			if (brutedamage >= 50)
				M.changeStatus("paralysis", 7 SECONDS)
			else if (brutedamage >= 30)
				M.changeStatus("stunned", 10 SECONDS)
			else if (brutedamage >= 20)
				M.changeStatus("weakened", 5 SECONDS)
			else
				M.changeStatus("weakened", 2 SECONDS)
			playsound(M.loc, pick('sound/impact_sounds/Slimy_Splat_1.ogg', 'sound/impact_sounds/Flesh_Break_1.ogg'), 75, 1)
			M.emote("scream")
		A.set_loc(T)
		return

// ====================== SUBTYPES OF PITFALL ======================
TYPEINFO(/datum/component/pitfall/target_landmark)
	initialization_args = list(
		ARG_INFO("BruteDamageMax", DATA_INPUT_NUM, "The maximum amount of random brute damage applied by the fall.", 0),
		ARG_INFO("FallTime", DATA_INPUT_NUM, "How long it takes for a thing to fall into the pit.", 0.3 SECONDS),
		ARG_INFO("TargetLandmark", DATA_INPUT_TEXT, "The landmark that the fall sends you to.", "")
	)
/// a pitfall that targets a pitfall landmark
/datum/component/pitfall/target_landmark
	Initialize(BruteDamageMax = 50, FallTime = 0.3 SECONDS, TargetLandmark = "")
		..()
		if (isnull(TargetLandmark))
			return COMPONENT_INCOMPATIBLE
		src.TargetLandmark = TargetLandmark

	try_fall(signalsender, atom/movable/AM)
		..()
		src.fall_to(pick_landmark(src.TargetLandmark), AM, src.BruteDamageMax)

TYPEINFO(/datum/component/pitfall/target_area)
	initialization_args = list(
		ARG_INFO("BruteDamageMax", DATA_INPUT_NUM, "The maximum amount of random brute damage applied by the fall.", 0),
		ARG_INFO("FallTime", DATA_INPUT_NUM, "How long it takes for a thing to fall into the pit.", 0.3 SECONDS),
		ARG_INFO("TargetArea", DATA_INPUT_TYPE, "The area typepath that the target falls into. If null, then it drops onto the same coordinates.", null)
	)
/// a pitfall that targets an area
/datum/component/pitfall/target_area
	Initialize(BruteDamageMax = 50, FallTime = 0.3 SECONDS, TargetArea = null)
		..()
		if (isnull(TargetArea) || !istype(TargetArea, /area))
			return COMPONENT_INCOMPATIBLE
		src.TargetArea = TargetArea

	update_targets()
		src.TargetList = list()
		for(var/T in get_area_turfs(src.TargetArea))
			src.TargetList += T

TYPEINFO(/datum/component/pitfall/target_coordinates)
	initialization_args = list(
		ARG_INFO("BruteDamageMax", DATA_INPUT_NUM, "The maximum amount of random brute damage applied by the fall.", 0),
		ARG_INFO("FallTime", DATA_INPUT_NUM, "How long it takes for a thing to fall into the pit.", 0.3 SECONDS),
		ARG_INFO("TargetZ", DATA_INPUT_NUM, "The z level that the target falls into.", 5),
		ARG_INFO("LandingRange", DATA_INPUT_NUM, "If true, try to find a spot around the target to land on in range (x). Only for 'direct drops'.", 0),
	)
/// a pitfall which targets a coordinate. At the moment only supports targeting a z level and picking a range around current coordinates.
/datum/component/pitfall/target_coordinates
	Initialize(BruteDamageMax = 50, FallTime = 0.3 SECONDS, TargetZ = 5, LandingRange = 8)
		..()
		if (isnull(TargetZ) || isnull(LandingRange))
			return COMPONENT_INCOMPATIBLE
		src.TargetZ			= TargetZ
		src.LandingRange	= LandingRange

	update_targets()
		src.TargetList = list()
		// since oshan and nadir allow for digging up and down, this code is specific to those maps
		// so it checks for space fluid turfs as valid targets.
		for(var/turf/space/fluid/T in range(src.LandingRange, locate(src.typecasted_parent().x, src.typecasted_parent().y , src.TargetZ)))
			src.TargetList += T
			break
		// this part is for checking linked sea ladders downward.
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
					picked_turf.linked_hole = src.typecasted_parent()
					src.typecasted_parent().add_simple_light("trenchhole", list(120, 120, 120, 120))
