ABSTRACT_TYPE(/datum/tether_fault)
/datum/tether_fault
	/// Tether fault effect. Returns TRUE if the effect fired.
	proc/effect(area/A, obj/machinery/gravity_tether/tether)
		return FALSE

ABSTRACT_TYPE(/datum/tether_fault/minor)
/datum/tether_fault/minor

/datum/tether_fault/minor/zero_gravity/effect(area/A, obj/machinery/gravity_tether/tether)
	. = ..()
	logTheThing(LOG_STATION, tether, "fault zeroed the gravity in [A] for one minute.")
	A.set_turf_gravity(0)
	SPAWN (60 SECONDS)
		A.reset_all_turf_gravity()


/datum/tether_fault/minor/random_gravity/effect(area/A, obj/machinery/gravity_tether/tether)
	. = ..()
	var/new_intensity = randfloat(0, tether.maximum_intensity)
	logTheThing(LOG_STATION, tether, "fault changed the gravity in [A] to randomly selected [new_intensity] for one minute.")
	A.set_turf_gravity(new_intensity)
	SPAWN (60 SECONDS)
		A.reset_all_turf_gravity()

// taken from artifact gravity well
/datum/tether_fault/minor/push_objects/effect(area/A, obj/machinery/gravity_tether/tether)
	var/list/turfs = get_area_turfs(A, floors_only=TRUE)
	if (!length(turfs))
		return FALSE
	var/turf/target_turf = pick(turfs)
	var/push = prob(50)

	var/obj/effect/grav_pulse/lense = new(target_turf)
	lense.pulse()

	for(var/turf/T in orange(3, target_turf))
		var/fuckcrap_limit = 0
		for (var/obj/V in T)
			if(fuckcrap_limit++ > 30)
				break
			if (V.anchored)
				continue
			if (push)
				step_away(V,target_turf)
			else
				step_towards(V,target_turf)
		fuckcrap_limit = min(fuckcrap_limit, 25)
		for (var/mob/living/M in T)
			if(fuckcrap_limit++ > 30)
				break
			if(isintangible(M))
				continue
			if (push)
				step_away(M,target_turf)
			else
				step_towards(M,target_turf)

	qdel(lense)

// TODO: 3-4 More minor faults

ABSTRACT_TYPE(/datum/tether_fault/major)
/datum/tether_fault/major

/datum/tether_fault/major/force_shift/effect(area/A, obj/machinery/gravity_tether/tether)
	. = ..()
	tether.attempt_gravity_change(randfloat(0, tether.maximum_intensity))

/datum/tether_fault/major/form_white_hole/effect(area/A, obj/machinery/gravity_tether/tether)
	. = ..()
	var/list/turfs = get_area_turfs(A, floors_only=TRUE)
	if (!length(turfs))
		return FALSE
	var/turf/T = pick(turfs)
	logTheThing(LOG_STATION, tether, "fault formed a white hole at [log_loc(T)]")
	new /obj/whitehole(pick(turfs))
	return TRUE

// TODO: 3-4 More major faults

/* These things are maybe a little too deadly? Maybe classic only. */
// /datum/tether_fault/major/form_black_hole/effect(area/A, obj/machinery/gravity_tether/tether)
// 	. = ..()
// 	var/list/turfs = get_area_turfs(A, floors_only=TRUE)
// 	if (!length(turfs))
// 		return FALSE
// 	var/turf/T = pick(turfs)
// 	logTheThing(LOG_STATION, tether, "fault formed a black hole at [log_loc(T)]")
// 	new /obj/anomaly/bhole_spawner(pick(turfs))
// 	return TRUE
