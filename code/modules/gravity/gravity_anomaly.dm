/// Gravitatonal Anomaly, potentially creates a white/black hole or several other gravity effects based on typepath
/obj/anomaly/gravitational
	name = "gravitational anomaly"
	desc = "Looking at this hurts your bones. Better not get too close."
	icon = 'icons/effects/particles.dmi'
	icon_state = "8x8ring"
	color = "#aa0099"
	alpha = 100
	plane = PLANE_NOSHADOW_BELOW
	anchored = ANCHORED_ALWAYS
	event_handler_flags = IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
	has_processing_loop = TRUE
	density = FALSE
	HELP_MESSAGE_OVERRIDE("Maybe someone else knows something about this...")

	var/fault_typepath = /datum/grav_fault //! Picks from any concrete subtype of given datum
	var/lifespan = 10 SECONDS //! How long the warning effects last before it triggers
	var/sound_counter = 1 //! how many process ticks between sounds
	var/distortion_count = 2 //! how many distortion particles to spawn and how powerful the cross-throw effect is

	var/obj/effect/grav_pulse/lense = null
	var/obj/effect/gravanom_pulse/effect = null
	var/datum/grav_fault/fault = null

/obj/anomaly/gravitational/New(loc, lifespan_override=null, triggered_by_event=null)
	..()
	var/turf/T = get_turf(src)
	var/fault_path = pick(concrete_typesof(src.fault_typepath))
	src.fault = new fault_path
	if (!src.fault)
		qdel(src)
		return
	src.effect = new /obj/effect/gravanom_pulse(src)
	src.lense = new /obj/effect/grav_pulse(src)
	src.vis_contents += src.effect
	src.vis_contents += src.lense
	animate(src, alpha = 0, time = rand(3,8), loop = -1, easing = LINEAR_EASING)
	animate(alpha = 100, time = rand(3,8), loop = -1, easing = LINEAR_EASING)

	if(!particleMaster.CheckSystemExists(/datum/particleSystem/grav_warning, src))
		particleMaster.SpawnSystem(new /datum/particleSystem/grav_warning(src, slice_amount=src.distortion_count))

	if (isnum(lifespan_override))
		src.lifespan = lifespan_override
	if (triggered_by_event)
		for_clients_in_range(C, get_turf(src), 15)
			boutput(C, SPAN_ALERT("The air grows [pick("wibbly", "wobbly")]. Something feels very slightly off."))
			shake_camera(C.mob, 6, 8)
	animate(src, alpha = 0, time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(alpha = initial(src.alpha), time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	src.lense.pulse()

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
		playsound(src.loc, 'sound/weapons/conc_grenade.ogg', 60, TRUE)
		src.visible_message(SPAN_ALERT("\The [src.name] collapses into itself!"))
		src.lense.pulse()
		src.fault.effect(T)
		qdel(src)


/obj/anomaly/gravitational/process()
	. = ..()
	if (src.sound_counter > 0)
		src.sound_counter--
		return
	playsound(src.loc, "sound/items/can_crush-[rand(1,3)].ogg", 50, FALSE, pitch=0.3)
	src.sound_counter = initial(src.sound_counter)

/obj/anomaly/gravitational/disposing()
	src.vis_contents -= src.effect
	src.vis_contents -= src.lense
	src.effect = null
	src.lense = null
	qdel(src.fault)
	src.fault = null
	. = ..()

/obj/anomaly/gravitational/Crossed(atom/movable/AM)
	. = ..()
	if (!AM.anchored)
		AM.throw_at(get_edge_cheap(get_turf(src), pick(cardinal)), 5*src.distortion_count, 1*src.distortion_count)

/obj/anomaly/gravitational/get_help_message(dist, mob/user)
	. = ..()
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.traitHolder.hasTraitInList(list("training_engineer", "training_scientist")))
			return "Mitigate \the [src] with a <b>Spatial Interdictor</b>."

/obj/anomaly/gravitational/minor
	name = "small gravitational anomaly"
	desc = "Looking at this hurts your bones. Better not get too close."
	lifespan = 10 SECONDS
	fault_typepath = /datum/grav_fault/minor
	color = "#990099"
	alpha = 100
	distortion_count = 1

/obj/anomaly/gravitational/major
	name = "concerning gravitational anomaly"
	desc = "Looking at this hurts your bones. You feel like you already should have been running."
	lifespan = 20 SECONDS
	fault_typepath = /datum/grav_fault/major
	color = "#cc0099"
	alpha = 150
	distortion_count = 2

/obj/anomaly/gravitational/extreme
	name = "angry gravitational anomaly"
	desc = "Looking at this hurts your bones. It's bad. Not good. Terrible. <b>Angry</b>."
	lifespan = 30 SECONDS
	fault_typepath = /datum/grav_fault/extreme
	color = "#ff0099"
	alpha = 200
	distortion_count = 4

/obj/effect/gravanom_pulse
	plane = PLANE_DISTORTION
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
	particles = new /particles/gravitational/anomaly

/datum/particleSystem/grav_warning
	var/amount = 4

	New(atom/location=null, particleTypeName=null, particleTime=null, particleColor=null, atom/target=null, particleSprite=null, slice_amount=4)
		src.amount = slice_amount
		..(location, "grav_warning", 5)

	Run()
		if (..())
			for(var/i=0, i<src.amount, i++)
				sleep(0.2 SECONDS)
				SpawnParticle()
			state = 1

/datum/particleType/grav_warning
	name = "grav_warning"
	icon = 'icons/effects/particles.dmi'
	icon_state = "32x32ring"

	MatrixInit()
		first = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.color = "#aa0099"
			par.alpha = 255

			first.Scale(0.1,0.1)
			par.transform = first

			first.Scale(80)
			animate(par, transform = first, time = 5, alpha = 5)
			first.Reset()

/// Creates particles to be used as displacements
/particles/gravitational/anomaly
	color = generator("num", 1, 5)
	gradient = list(0, "#900", 1, "#600", 2, "#990", 3, "#660", 4, "#090", 5, "#060", "loop")

	icon = 'icons/effects/particles.dmi'
	icon_state = "mistcloud1"
	transform = list(1, 0, 0, 0,
	                 0, 1, 0, 0,
					 0, 0, 0, 1,
					 0, 0, 0, 1)

	spawning = 0.1
	count = 4
	lifespan = 5000
	spin = generator("num", -2, 2)
	grow = generator("num", 0.2, 0.5)
	fadein = 8
	position = generator("circle", 50, 100, UNIFORM_RAND)
	gravity = list(0, 0, 0.05)
	velocity = list(0, 0, 0.5)
	friction = 0.2

ABSTRACT_TYPE(/datum/grav_fault)
/// A fault effect for gravitational anomalies
/datum/grav_fault
	/// Tether fault effect, typically all you need to define
	proc/effect(turf/origin)

ABSTRACT_TYPE(/datum/grav_fault/minor)
/datum/grav_fault/minor

// taken from artifact gravity well
/datum/grav_fault/minor/push_objects/effect(turf/origin)
	. = ..()
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

// hee hee hoo hoo
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
	var/amount_left = 3
	for (var/turf/T in orange(6, origin))
		if (prob(70))
			continue
		SPAWN(rand(5 SECONDS, 50 SECONDS))
			new /obj/anomaly/gravitational/minor(T, lifespan_override=(20 SECONDS) + (rand(5, 15) SECONDS))
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

/// fall down go boom
/datum/grav_fault/major/trip/effect(turf/origin)
	. = ..()
	logTheThing(LOG_STATION, src, "caused everyone to trip near [log_loc(origin)]")
	for (var/mob/living/M in hearers(6, origin))
		if (M.anchored)
			return
		boutput(M, SPAN_ALERT("A gravitational anomaly pulls you off your feet!"))
		M.throw_at(get_step(origin, pick(alldirs)), 1, 1)

/// Rare events that have major effects on the round
ABSTRACT_TYPE(/datum/grav_fault/extreme)
/datum/grav_fault/extreme

#ifndef RP_MODE
/// Spawns a black hole spawner.
/datum/grav_fault/extreme/black_hole/effect(turf/origin)
	. = ..()
	SPAWN(0) // otherwise bhole_spawner eats the anomaly prematurely
		var/obj/anomaly/bhole_spawner/bhole = new(origin) // It's spawners all the way down
		bhole.feedings = 6 // not random event, so make these less hungry.
		logTheThing(LOG_STATION, src, "spawned a black hole spawner at [log_loc(origin)].")
		message_admins("Black Hole anomaly spawning in [log_loc(origin)]")
		message_ghosts("<b>A black hole</b> is spawning at [log_loc(origin, ghostjump=TRUE)].")
#endif

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
		if (M.lying)
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
				if(H.sever_limb("l_arm"))
					lost_limb = TRUE
				else if(H.sever_limb("r_arm"))
					lost_limb = TRUE
			else
				if(H.sever_limb("r_arm"))
					lost_limb = TRUE
				else if(H.sever_limb("l_arm"))
					lost_limb = TRUE
		if (lost_limb)
			boutput(M, SPAN_COMBAT("Your arm is ripped right off by the gravitational anomaly!"))

/// Spawns three major gravitational effects
/datum/grav_fault/extreme/gravity_storm/effect(turf/origin)
	. = ..()
	var/area/A = get_area(origin)
	if (!A)
		return
	logTheThing(LOG_STATION, src, "spawned several major gravitational anomalies around [log_loc(origin)]")
	var/list/target_turfs = get_area_turfs(A, floors_only=TRUE)
	shuffle_list(target_turfs)
	var/amount_left = 3
	for (var/turf/T in orange(6, origin))
		if (prob(70))
			continue
		SPAWN(rand(5 SECONDS, 50 SECONDS))
			new /obj/anomaly/gravitational/major(T, lifespan_override=(20 SECONDS) + (rand(5, 15) SECONDS))
		amount_left -= 1
		if (amount_left <= 0)
			break
