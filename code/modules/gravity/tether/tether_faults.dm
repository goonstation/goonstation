ABSTRACT_TYPE(/datum/tether_fault)
/// Faults for the gravity tether
///
/// Separated into MAJOR and MINOR subtypes. Always needs a target area to operate in.
/datum/tether_fault
	/// Tether fault effect. Returns TRUE if the effect fired.
	proc/effect(area/A, fault_source=null)
		return FALSE

	proc/log_fault(fault_source=null, message)
		if (istype(fault_source, /obj/machinery/gravity_tether))
			logTheThing(LOG_STATION, fault_source, "Tether fault [message]")
		else if (istype(fault_source, /obj/anomaly/gravitational))
			logTheThing(LOG_STATION, fault_source, "Anomaly fault [message]")
		else if (isnull(fault_source))
			logTheThing(LOG_STATION, src, "No fault source!! [message]")
		else
			logTheThing(LOG_STATION, fault_source, "Unknown fault [message]")

	proc/get_maximum_intensity(fault_source=null)
		. = TETHER_INTENSITY_MAX_EMAG
		if (istype(fault_source, /obj/machinery/gravity_tether))
			var/obj/machinery/gravity_tether/tether = fault_source
			. = tether.maximum_intensity
		else if (istype(fault_source, /obj/anomaly/gravitational))
			var/obj/anomaly/gravitational/anomaly = fault_source
			. = anomaly.maximum_intensity


ABSTRACT_TYPE(/datum/tether_fault/minor)
/datum/tether_fault/minor

/datum/tether_fault/minor/zero_gravity/effect(area/A, fault_source=null)
	. = ..()
	src.log_fault(fault_source, "zeroed the gravity in [A] for one minute.")
	A.set_turf_gravity(0)
	SPAWN (60 SECONDS)
		A?.reset_all_turf_gravity()

/datum/tether_fault/minor/random_area/effect(area/A, fault_source=null)
	. = ..()
	var/new_intensity = randfloat(0, src.get_maximum_intensity(fault_source))
	src.log_fault(fault_source, "change area [A] gravity to random [new_intensity]G for one minute.")
	A.set_turf_gravity(new_intensity)
	SPAWN (60 SECONDS)
		A?.reset_all_turf_gravity()

// taken from artifact gravity well
/datum/tether_fault/minor/push_objects/effect(area/A, fault_source=null)
	var/list/turfs = get_area_turfs(A, floors_only=TRUE)
	if (!length(turfs))
		return FALSE
	var/turf/target_turf = pick(turfs)
	var/push = prob(50)

	var/obj/effect/grav_pulse/lense = new(target_turf)
	target_turf.vis_contents += lense
	lense.pulse()
	src.log_fault(fault_source, "pushed around a bunch of objects at [log_loc(target_turf)].")

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
	target_turf.vis_contents -= lense
	qdel(lense)

/datum/tether_fault/minor/fart/effect(area/A, fault_source=null)
	. = ..()
	src.log_fault(fault_source, "made everyone fart in [A].")
	for (var/mob/living/M in global.mobs)
		if (isalive(M) && get_area(M) == A)
			M.emote("fart")

// TODO: 3-4 More minor faults

ABSTRACT_TYPE(/datum/tether_fault/major)
/datum/tether_fault/major

/datum/tether_fault/major/force_shift/effect(area/A, fault_source=null)
	. = ..()
	var/obj/machinery/gravity_tether/target_tether = fault_source
	if (!istype(target_tether) && isatom(fault_source))
		var/atom/atom = fault_source
		var/list/tethers = list()
		for (var/obj/machinery/gravity_tether/tether as anything in by_cat[TR_CAT_GRAVITY_TETHERS])
			if(tether.z == atom.z)
				tethers.Add(tether)
		if (length(tethers))
			target_tether = pick(tethers)
	if (!istype(target_tether))
		src.log_fault(LOG_STATION, fault_source, "failed to cause a tether force shift fault!")
		return

	var/target_intensity = randfloat(0, target_tether.maximum_intensity)
	src.log_fault(target_tether, "attempted force shift to [target_intensity] ")
	target_tether.attempt_gravity_change(target_intensity)

/datum/tether_fault/major/form_white_hole/effect(area/A, fault_source=null)
	. = ..()
	var/list/turfs = get_area_turfs(A, floors_only=TRUE)
	if (!length(turfs))
		return FALSE
	var/turf/T = pick(turfs)
	src.log_fault(fault_source, "formed a white hole at [log_loc(T)].")
	new /obj/whitehole(pick(turfs))
	return TRUE

/datum/tether_fault/major/random_turfs/effect(area/A, fault_source=null)
	. = ..()
	var/max_intensity = src.get_maximum_intensity(fault_source)
	src.log_fault(fault_source, "randomized individual turf gravity between 0 and [max_intensity]G in [A].")
	for (var/turf/simulated/T in global.get_area_turfs(A))
		T.set_gravity(A.gforce_minimum, randfloat(0, max_intensity))
	SPAWN (120 SECONDS)
		A?.reset_all_turf_gravity()

// TODO: 3-4 More major faults

/// Spawns gravity fault effects
/obj/anomaly/gravitational
	name = "gravitational anomaly"
	desc = ""
	icon = 'icons/effects/overlays/lensing.dmi'
	icon_state="blank"
	plane = PLANE_DISTORTION
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
	has_processing_loop = TRUE
	var/fault_type = /datum/tether_fault //! Picks from any concrete subtype of given datum
	var/maximum_intensity = TETHER_INTENSITY_MAX_EMAG
	var/obj/effect/grav_pulse/lense

	New(loc, lifespan=7 SECONDS, obj/machinery/gravity_tether/source_tether=null)
		..()
		lense = new()
		src.vis_contents += lense
		SPAWN (lifespan)
			var/fault_path = pick(concrete_typesof(src.fault_type))
			var/datum/tether_fault/fault = new fault_path
			var/area/A = get_area(src)
			if (istype(source_tether))
				fault?.effect(A, source_tether)
			else
				fault?.effect(A, src)
			qdel(src)

	disposing()
		lense = null
		qdel(lense)
		. = ..()

	process()
		. = ..()
		lense?.pulse()

/obj/anomaly/gravitational/minor
	fault_type = /datum/tether_fault/minor

/obj/anomaly/gravitational/major
	fault_type = /datum/tether_fault/major
