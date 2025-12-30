/// Spawns a gravitational anomaly in a turf it controls, based on the given probability.
///
/// Will automatically target a random area this tether controls unless given an area refere
/obj/machinery/gravity_tether/proc/random_fault(major_prob=0)
	if (src.has_no_power())
		return
	if (!length(src.target_area_refs))
		return
	var/area/target_area = pick(src.target_area_refs)
	if (!istype(target_area))
		return

	var/list/turfs = get_area_turfs(target_area, TRUE)
	if (!length(turfs))
		turfs = get_area_turfs(target_area, FALSE)
		if (!length(turfs))
			return

	if (prob(major_prob))
		if (prob(5))
			new /obj/anomaly/gravitational/extreme(pick(turfs))
			return
		if (prob(20))
			src.randomize_gravity()
			return
		new /obj/anomaly/gravitational/major(pick(turfs))
		return
	if (prob(20))
		src.gravity_drift()
		return
	new /obj/anomaly/gravitational/minor(pick(turfs))

/// Generate oods of a fault occuring based on tether state
/obj/machinery/gravity_tether/proc/calculate_fault_chance(start_value=0)
	. = start_value
	if (src.gforce_intensity != 1) // non-standard intensities may introduce problems. scales with intensity
		. += src.gforce_intensity * 2
	switch (src.wire_state) // keep your machine taken care of
		if(TETHER_WIRES_INTACT)
			. += 0
		if(TETHER_WIRES_BURNED)
			. += 15
		if(TETHER_WIRES_CUT)
			. += 30
	. = round(clamp(., 0, 100))

/obj/machinery/gravity_tether/proc/gravity_drift()
	src.change_intensity(src.gforce_intensity + prob(50) ? 0.01: -0.01)

/obj/machinery/gravity_tether/proc/randomize_gravity()
	var/chosen_gforce = randfloat(0, src.maximum_intensity)
	if (chosen_gforce == src.gforce_intensity)
		return
	src.attempt_gravity_change(chosen_gforce)

/// Spawns gravity fault effects
/obj/anomaly/gravitational
	name = "baby gravitational anomaly"
	desc = "Aww. It's so cute!"
	icon = 'icons/effects/64x64.dmi'
	icon_state="smoke-unused"
	bound_width = 32
	bound_height = 32
	pixel_x = -16
	pixel_y = -16
	alpha = 50
	anchored = ANCHORED_ALWAYS
	event_handler_flags = IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
	plane = PLANE_NOSHADOW_BELOW

	var/fault_type = /datum/grav_fault //! Picks from any concrete subtype of given datum
	var/lifespan = 30 SECONDS

	New(loc, lifespan_override=null, triggered_by_event=null)
		..()
		if (!isnum(lifespan_override))
			src.lifespan = lifespan_override
		if (triggered_by_event)
			var/turf/T = get_turf(src)
			for (var/client/C in GET_NEARBY(/datum/spatial_hashmap/clients, T, 19))
				boutput(C, SPAN_ALERT("The air grows hazy. Something feels slightly wrong."))
				shake_camera(C.mob, 6, 8)

		animate(src, lifespan - 2 SECONDS, alpha=255, transform=matrix(2, 0, 0, 2, 0 ,0))
		SPAWN (lifespan)
			if (QDELETED(src))
				return
			for_by_tcl(IX, /obj/machinery/interdictor)
				if (IX.expend_interdict(500, src))
					if(prob(20))
						playsound(IX,'sound/machines/alarm_a.ogg',20,FALSE,5,-1.5)
						IX.visible_message(SPAN_ALERT("<b>[IX] emits an anti-gravitational anomaly warning!</b>"))
					SPAWN(rand(1,8))
						playsound(src.loc, "sparks", 60, 1)
					qdel(src)
					return
			var/turf/T = get_turf(src)
			var/fault_path = pick(concrete_typesof(src.fault_type))
			var/datum/grav_fault/fault = new fault_path
			fault?.effect(T)
			qdel(src)

/obj/anomaly/gravitational/minor
	fault_type = /datum/grav_fault/minor

/obj/anomaly/gravitational/major
	lifespan = 45 SECONDS
	fault_type = /datum/grav_fault/major

/obj/anomaly/gravitational/extreme
	lifespan = 60 SECONDS
	fault_type = /datum/grav_fault/extreme

ABSTRACT_TYPE(/datum/grav_fault)
/// A fault effect for gravitational anomalies
/datum/grav_fault

	/// Tether fault effect, typically all you need to define
	proc/effect(turf/origin)

ABSTRACT_TYPE(/datum/grav_fault/minor)
/datum/grav_fault/minor

// taken from artifact gravity well
/datum/grav_fault/minor/push_objects/effect(turf/origin)
	var/push = prob(50)

	var/obj/effect/grav_pulse/lense = new(origin)
	origin.vis_contents += lense
	lense.pulse()
	logTheThing(LOG_STATION, src, "pushed around a bunch of objects at [log_loc(origin)].")

	for(var/turf/T in orange(3, origin))
		var/fuckcrap_limit = 0
		for (var/obj/V in T)
			if(fuckcrap_limit++ > 30)
				break
			if (V.anchored)
				continue
			if (push)
				step_away(V,origin)
			else
				step_towards(V,origin)
		fuckcrap_limit = min(fuckcrap_limit, 25)
		for (var/mob/living/M in T)
			if(fuckcrap_limit++ > 30)
				break
			if(isintangible(M))
				continue
			if (push)
				step_away(M,origin)
			else
				step_towards(M,origin)
	origin.vis_contents -= lense
	qdel(lense)

/datum/grav_fault/minor/fart/effect(turf/origin)
	. = ..()
	logTheThing(LOG_STATION, src, "caused everyone to fart near [log_loc(origin)].")
	for (var/mob/living/M in hearers(6, origin))
		if (isalive(M))
			M.emote("fart")

/datum/grav_fault/minor/drop/effect(turf/origin)
	. = ..()
	logTheThing(LOG_STATION, src, "caused everyone to drop/unquip items near [log_loc(origin)].")
	for (var/mob/living/M in hearers(6, origin))
		if (!isalive(M))
			continue

		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			boutput(H, SPAN_ALERT("A gravitational anomaly makes you drop everything!"))
			if (H.l_hand)
				H.drop_item(H.l_hand)
			if (H.r_hand)
				H.drop_item(H.r_hand)
		else if (isrobot(M))
			var/mob/living/silicon/robot/R = M
			boutput(R, SPAN_ALERT("A gravitational anomaly unquipped one of your tools!"))
			R.unequip_random()
		else if (ismobcritter(M))
			var/mob/living/critter/C = M
			boutput(C, SPAN_ALERT("A gravitational anomaly makes you drop everything!"))
			C.empty_hands()

/datum/grav_fault/minor/single_dir_push/effect(turf/origin)
	. = ..()
	logTheThing(LOG_STATION, src, "moved people in the same direction around [log_loc(origin)].")
	var/chosen_dir = pick(alldirs)
	for (var/mob/living/M in hearers(6, origin))
		step(M, chosen_dir)

/datum/grav_fault/minor/single_dir_push/effect(turf/origin)
	. = ..()
	logTheThing(LOG_STATION, src, "moved people in the same direction around [log_loc(origin)].")

ABSTRACT_TYPE(/datum/grav_fault/major)
/datum/grav_fault/major

/// Spawns a bunch of minor effects
/datum/grav_fault/major/gravity_storm/effect(turf/origin)
	. = ..()
	var/area/A = get_area(origin)
	if (!A)
		return
	logTheThing(LOG_STATION, src, "spawned several minor gravitational anomalies around [log_loc(origin)]")
	var/list/target_turfs = get_area_turfs(A, floors_only=TRUE)
	shuffle_list(target_turfs)
	var/amount_left = 5
	for (var/turf/T in orange(6, origin))
		if (prob(70))
			continue
		SPAWN(rand(5 SECONDS, 50 SECONDS))
			new /obj/anomaly/gravitational/minor(origin, lifespan_override=(20 SECONDS) + (rand(5, 15) SECONDS))
		amount_left -= 1
		if (amount_left <= 0)
			break

/// Singularity bholerip effect, breaks down walls and breaks floors (does not delete floors)
/datum/grav_fault/major/bholerip/effect(turf/origin)
	. = ..()
	logTheThing(LOG_STATION, src, "did a bholerip effect at [log_loc(origin)].")
	for (var/turf/T in orange(6, origin))
		if (prob(60))
			continue

		if (T && !istype(T, /turf/space) && (IN_EUCLIDEAN_RANGE(origin, T, 6)))
			if (issimulatedturf(T))
				if (istype(T,/turf/simulated/floor) && !istype(T,/turf/simulated/floor/plating))
					var/turf/simulated/floor/F = T
					if (!F.broken)
						if (prob(80))
							F.break_tile_to_plating()
							if(!F.intact)
								var/obj/item/tile/tile = new(F)
								tile.setMaterial(F.material)
						else
							F.break_tile()
				else if (istype(T, /turf/simulated/wall))
					var/turf/simulated/wall/W = T
					if (istype(W, /turf/simulated/wall/r_wall) || istype(W, /turf/simulated/wall/auto/reinforced))
						new /obj/structure/girder/reinforced(W)
					else
						new /obj/structure/girder(W)
					var/obj/item/sheet/S = new /obj/item/sheet(W)
					if (W.material)
						S.setMaterial(W.material)
					else
						var/datum/material/M = getMaterial("steel")
						S.setMaterial(M)
					W.ReplaceWithFloor()
	return

/// Everyone throws their items
/datum/grav_fault/major/yeet/effect(turf/origin)
	. = ..()
	logTheThing(LOG_STATION, src, "caused everyone to throw items near [log_loc(origin)].")
	for (var/mob/living/M in hearers(6, origin))
		if (!isalive(M))
			continue
		var/did_drop = FALSE
		if (isrobot(M))
			var/mob/living/silicon/robot/R = M
			R.uneq_all()
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.l_hand)
				H.drop_item_throw(H.l_hand)
				did_drop = TRUE
			if (H.r_hand)
				H.drop_item_throw(H.r_hand)
				did_drop = TRUE
		else if (ismobcritter(M))
			var/mob/living/critter/C = M
			for (var/datum/handHolder/HH in C.hands)
				if (HH.item)
					C.drop_item_throw(HH.item)
					did_drop = TRUE
		if (did_drop)
			boutput(M, SPAN_ALERT("A gravitational anomaly pulls the items out of your hands!"))

/datum/grav_fault/major/trip/effect(turf/origin)
	logTheThing(LOG_STATION, src, "caused everyone to trip near [log_loc(origin)]")
	for (var/mob/living/M in hearers(6, origin))
		if (M.anchored)
			return
		boutput(M, SPAN_ALERT("A gravitational anomaly pulls you off your feet!"))
		M.throw_at(get_step(origin, pick(alldirs)), 1, 1)

/// Rare events that have major effects on the round
ABSTRACT_TYPE(/datum/grav_fault/extreme)
/datum/grav_fault/extreme

/// Spawns a black hole spawner.
/datum/grav_fault/extreme/black_hole/effect(turf/origin)
	. = ..()
	var/obj/anomaly/bhole_spawner/bhole = new(origin) // It's spawners all the way down
	bhole.feedings = 6 // not random event, so make these less hungry.
	logTheThing(LOG_STATION, src, "spawned a black hole spawner at [log_loc(origin)].")
	message_admins("Black Hole anomaly spawning in [log_loc(origin)]")
	message_ghosts("<b>A black hole</b> is spawning at [log_loc(origin, ghostjump=TRUE)].")

/// Wow! Free white hole!
/datum/grav_fault/extreme/white_hole/effect(turf/origin)
	. = ..()

	var/obj/whitehole/white_hole = new /obj/whitehole(origin, 2 MINUTES + rand(-300, 300), 40 SECONDS + rand(-100, 100), triggered_by_event=TRUE)
	logTheThing(LOG_STATION, src, "formed a white hole anomaly with origin [white_hole.source_location] at [log_loc(origin)].")
	message_admins("White Hole anomaly with origin [white_hole.source_location] spawning in [log_loc(origin)]")
	message_ghosts("<b>\A [white_hole.source_location] white hole</b> is spawning at [log_loc(origin, ghostjump=TRUE)].")

/// Rips off a single arm from nearby mobs
/datum/grav_fault/extreme/rip_arms/effect(turf/origin)
	. = ..()
	logTheThing(LOG_STATION, src, "tried ripping arms off near [log_loc(origin)].")
	var/lost_limb = FALSE
	for (var/mob/living/M in hearers(6, origin))
		if (M.lying || prob(30))
			continue
		if (isrobot(M))
			var/mob/living/silicon/robot/R = M
			if (prob(50))
				if (R.part_arm_l)
					R.compborg_lose_limb(R.part_arm_l)
					lost_limb = TRUE
				else if (R.part_arm_r)
					R.compborg_lose_limb(R.part_arm_r)
					lost_limb = TRUE
			else
				if (R.part_arm_r)
					R.compborg_lose_limb(R.part_arm_r)
					lost_limb = TRUE
				else if (R.part_arm_l)
					R.compborg_lose_limb(R.part_arm_l)
					lost_limb = TRUE
		else if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (prob(50))
				if (H.limbs.l_arm)
					H.sever_limb(H.limbs.l_arm)
					lost_limb = TRUE
				else if (H.limbs.r_arm)
					H.sever_limb(H.limbs.r_arm)
					lost_limb = TRUE
			else
				if (H.limbs.r_arm)
					H.sever_limb(H.limbs.r_arm)
					lost_limb = TRUE
				else if (H.limbs.l_arm)
					H.sever_limb(H.limbs.l_arm)
					lost_limb = TRUE
		if (lost_limb)
			boutput(M, SPAN_COMBAT("Your arm is ripped right off by the gravitational anomaly!"))
