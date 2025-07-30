
// I came here with good intentions, I swear, I didn't know what this code was like until I was already waist deep in it

/**
 * Checks if there is a containment field in each direction from the center turf. If not returns null.
 * If yes returns the distance to the closest field.
 */
proc/singularity_containment_check(turf/center)
	var/min_dist = INFINITY
	for(var/dir in alldirs)
		var/turf/T = center
		var/found_field = FALSE
		for(var/i in 1 to 20)
			T = get_step(T, dir)
			if(locate(/obj/machinery/containment_field) in T)
				min_dist = min(min_dist, i)
				found_field = TRUE
				break
			// in case people make really big singulo cages using multiple generators we want to count an contained generator as a containment field too
			for(var/obj/machinery/field_generator/field_generator in T)
				if(field_generator.active && field_generator.active_dirs != 0) // TODO: require at least two dirs maybe? but note that active_dirs is a BIT FIELD
					found_field = TRUE
					min_dist = min(min_dist, i)
					break
		if(!found_field)
			return null
	return min_dist

/obj/machinery/the_singularity/
	name = "gravitational singularity"
	desc = "Perhaps the densest thing in existence, except for you."
	plane = PLANE_DEFAULT_NOWARP
	icon = 'icons/effects/64x64.dmi'
	icon_state = "whole"
	anchored = ANCHORED
	density = TRUE
	event_handler_flags = IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP
	deconstruct_flags = DECON_NONE
	flags = 0 // no fluid submerge images and we also don't need tgui interactability
	pixel_x = -16
	pixel_y = -16
	var/contained = FALSE //! Value which stores whether it is currently under containment
	var/stored_energy = 10 //! Amount of energy the singularity has absorbed from objects. If at or below 0, the singularity dissapears
	var/duration_to_live = null //! The amount of time in seconds the singularity will live for before expiring, in seconds. If null, it lives forever.
	var/worldtime_spawned = null //! The world.time that this singularity was spawned. Used to keep track of time to live for event singularities
	var/die_over_time = FALSE //! If enabled, the singularity will slowly lose stored_energy and be deleted when it runs at or below 0.
	var/self_move = TRUE //! Controls whether or not the singularity moves on its own.
	var/gravity_pull_radius = 6 //! The initial radius, in tiles, that the singularity will pull objects within. Changes with radius
	var/radius = 0 //! the variable used for all calculations involving radius.
	var/max_radius = INFINITY //! the maximum radius the singularity can grow to. Overriden on init to a sensible value
	var/restricted_z_allowed = FALSE //! Whether to annihilate this singularity if it is spawned on restricted z-levels. You can probably guess why
	var/right_spinning = null //! boolean for the spaghettification animation spin direction
	var/spaget_count = 0 //! Count for rate-limiting the spaghettification effect
	var/katamari_mode = FALSE //! If true the sucked-in objects will get stuck to the singularity
	var/num_absorbed = 0 //! Number of objects absorbed by the singularity
	var/num_absorbed_players = 0 //! number of players absorbed
	var/gib_mobs = FALSE //! if it should call gib on mobs
	var/list/succ_cache //! An associative list of object types consumed to the number of times eaten, used for diminishing returns on energy.
	var/turf/target_turf //! Targeted turf when loose
	var/target_turf_counter = 0 //! How many steps we'll continue to walk towards the target turf before rerolling

#ifdef SINGULARITY_TIME

/*
hello I've lost my remaining sanity by dredging this code from the depths of hell where it was cast eons before I arrived in this place
for some reason I brought it back and tried to clean it up a bit and I regret everything but it's too late now I can't put it back please forgive me
- haine
*/

/*
starting_energy: The amount of energy the singularity will start with. Indirectly related to the radius and with death over time (decay)
seconds_to_live: Relevant with event singularities, this is the time (in seconds) the singularity will be around before being qdel'd
maximum_radius: Sets the initial maximum radius of the singularity.
*/
/obj/machinery/the_singularity/New(loc, var/starting_energy = 100, var/seconds_to_live = null, var/maximum_radius = 2)
	START_TRACKING
	START_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)
	src.stored_energy = starting_energy
	src.max_radius = maximum_radius
	src.succ_cache = list()
	src.radius = min(src.max_radius, src.radius) // Reduce the starting radius if the initial radius is set lower than the maximum radius
	SafeScale((src.radius+1)/3.0,(src.radius+1)/3.0)
	src.gravity_pull_radius = (radius+1)*3
	event()
	src.duration_to_live = seconds_to_live
	src.right_spinning = prob(50)

	var/offset = rand(1000)
	add_filter("loose rays", 1, rays_filter(size=1, density=10, factor=0, offset=offset, threshold=0.2, color="#c0c", x=0, y=0))
	animate(get_filter("loose rays"), offset=offset+60, time=5 MINUTES, easing=LINEAR_EASING, flags=ANIMATION_PARALLEL, loop=-1)

	//get all bendy

	var/image/lense = image(icon='icons/effects/overlays/lensing.dmi', icon_state="lensing_med_hole", pixel_x = -208, pixel_y = -208)
	lense.plane = PLANE_DISTORTION
	lense.blend_mode = BLEND_OVERLAY
	lense.appearance_flags = RESET_ALPHA | RESET_COLOR
	src.UpdateOverlays(lense, "grav_lensing")
	..()

/obj/machinery/the_singularity/disposing()
	STOP_TRACKING
	STOP_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)
	. = ..()

/obj/machinery/the_singularity/process()
	var/turf/T = get_turf(src)
	if(isrestrictedz(T?.z) && !src.restricted_z_allowed)
		src.visible_message(SPAN_NOTICE("Something about this place makes [src] wither and implode."))
		qdel(src)
	eat()

	if (src.duration_to_live)//If its a temp singularity IE: an event
		// This is the first time we are processing this temporary singularity, mark down when it spawned!
		if (src.worldtime_spawned == 0)
			src.worldtime_spawned = world.time
			return
		if ((src.worldtime_spawned + src.duration_to_live) <= world.time)
			qdel(src)

	if (src.die_over_time)
		if (src.stored_energy <= 0) // Singularity dies if its out of stored energy
			qdel(src)
		else
			src.stored_energy -= 15


	if (prob(20))//Chance for it to run a special event
		event()

	if (src.contained)
		move()
		SPAWN(2 SECONDS) // slowing this baby down a little -drsingh // smoother movement
			move()

			var/recapture_prob = clamp(25-(src.radius**2) , 0, 25)
			if (prob(recapture_prob))
				var/check_max_radius = singularity_containment_check(get_turf(src))
				if (!isnull(check_max_radius) && check_max_radius >= src.radius)
					src.contained = FALSE
					animate(get_filter("loose rays"), size=1, time=5 SECONDS, easing=LINEAR_EASING, flags=ANIMATION_PARALLEL, loop=1)
					src.max_radius = check_max_radius
					logTheThing(LOG_STATION, null, "[src] has been contained (at max_radius [max_radius]) at [log_loc(src)]")
					message_admins("[src] has been contained (at max_radius [max_radius]) at [log_loc(src)]")

	else
		var/check_max_radius = singularity_containment_check(get_turf(src))
		if (isnull(check_max_radius) || check_max_radius < src.radius)
			src.contained = TRUE
			animate(get_filter("loose rays"), size=100, time=5 SECONDS, easing=LINEAR_EASING, flags=ANIMATION_PARALLEL, loop=1)
			src.max_radius = INFINITY
			logTheThing(LOG_STATION, null, "[src] has become loose at [log_loc(src)]")
			message_admins("[src] has become loose at [log_loc(src)]")
			message_ghosts("<b>[src]</b> has become loose at [log_loc(src, ghostjump=TRUE)].")

/obj/machinery/the_singularity/emp_act()
	return // No action required this should be the one doing the EMPing

#define MAX_AFFECTED_ATOMS_PER_TURF 30 //! Prevents lag from eating an overwhelming amount of items on one turf

/obj/machinery/the_singularity/proc/eat()

	var/turf/sing_center = src.get_center()
	for (var/turf/T in range(src.gravity_pull_radius, sing_center))
		var/affected_atoms = 0
		for (var/atom/A in list(T) + T.contents)
			if (affected_atoms++ >= MAX_AFFECTED_ATOMS_PER_TURF)
				break

			if (A == src)
				continue

			if (A.event_handler_flags & IMMUNE_SINGULARITY)
				continue

			if (!src.contained)
				if (A.event_handler_flags & IMMUNE_SINGULARITY_INACTIVE)
					continue

			if(IN_EUCLIDEAN_RANGE(sing_center, A, src.radius + 0.5))
				src.Bumped(A)

			else if (istype(A, /atom/movable))
				var/atom/movable/AM = A
				if (!AM.anchored)
					step_towards(AM, src)

#undef MAX_AFFECTED_ATOMS_PER_TURF

/obj/machinery/the_singularity/proc/move()
	// if we're inside something (e.g posessed mob) dont move
	if (!isturf(src.loc))
		return

	if (src.self_move)
		var/list/vector = src.calc_direction()
		var/next_dir = pick(alldirs)

		if (src.target_turf_counter <= 0)
			if (prob(20)) // drift towards a random station turf for a few steps
				src.target_turf = get_random_station_turf()
				src.target_turf_counter = rand(src.radius, src.radius*2)
		else
			if (!src.target_turf)
				src.target_turf = get_random_station_turf()
			src.target_turf_counter--
			next_dir = get_dir_accurate(src, src.target_turf)

		var/vector_length = (vector[1] ** 2 + vector[2] ** 2) ** (1/2)
		if (prob(vector_length * 400)) //scale the chance to move in the direction of resultant force by the strength of that force
			var/angle = arctan(vector[2], vector[1])
			next_dir = angle2dir(angle)

		// don't cross containment fields
		for (var/dist = max(0, (src.radius - 1)), dist <= (src.radius + 1), dist++)
			var/turf/checkloc = get_ranged_target_turf(src.get_center(), next_dir, dist)
			if (locate(/obj/machinery/containment_field) in checkloc)
				return

		step(src, next_dir)

///Returns a 2D vector representing the resultant force acting on the singulo by all gravity wells, scaled by their distance
/obj/machinery/the_singularity/proc/calc_direction()
	var/list/total_vector = list(0,0) //if only we had vector primitives...
	var/turf/singulo_turf = get_turf(src)
	//unfortunately these are two unrelated types that both have special behaviour so this is going to get messy
	for (var/atom/movable/magnet as anything in by_cat[TR_CAT_SINGULO_MAGNETS])
		var/turf/magnet_turf = get_turf(magnet)
		if (magnet_turf.z != singulo_turf.z)
			continue

		var/sign = -1 //default to pull
		if (istype(magnet, /obj/machinery/artifact))
			var/obj/machinery/artifact/artifact = magnet
			var/datum/artifact/gravity_well_generator/artifact_datum = artifact.artifact
			if (istype(artifact_datum) && !artifact_datum.activated)
				continue
			if (artifact_datum.gravity_type == 1)
				sign = 1 //push
		if (istype(magnet, /obj/gravity_well_generator))
			var/obj/gravity_well_generator/generator = magnet
			if (!generator.active)
				continue

		//our actual offset from this magnet
		var/list/vector = list(0,0)
		vector[1] = ((singulo_turf.x - magnet_turf.x) * sign)
		vector[2] = ((singulo_turf.y - magnet_turf.y) * sign)
		//no need to root, we can reuse the squared value (I'm basically a doom programmer)
		var/length_squared = (vector[1] ** 2) + (vector[2] ** 2)
		//inverse square law I guess? gravity is radial
		total_vector[1] += vector[1] * 1/length_squared
		total_vector[2] += vector[2] * 1/length_squared
	return total_vector

/obj/machinery/the_singularity/ex_act(severity, last_touched, power)
	if (severity == 1 && prob(power * 5)) //need a big bomb (TTV+ sized), but a big enough bomb will always clear it
		var/turf/T = get_turf(src)
		qdel(src)
		new /obj/bhole(T,rand(100,300))

/obj/machinery/the_singularity/Bumped(atom/A)
	if (istype(A, /obj/dummy))
		return

	if (A.event_handler_flags & IMMUNE_SINGULARITY)
		return

	if (!contained)
		if (A.event_handler_flags & IMMUNE_SINGULARITY_INACTIVE)
			return

	if(QDELETED(A)) // Don't bump that which no longer exists
		return
	src.consume_atom(A)

/obj/machinery/the_singularity/proc/consume_atom(atom/A, no_visuals = FALSE)
	var/gain = 0

	if(!no_visuals)
		src.num_absorbed++
		if(src.spaget_count < 25 && !src.katamari_mode)
			src.spaget_count++
			animate_spaghettification(A, src, 15 SECONDS, src.right_spinning)
			SPAWN(16 SECONDS)
				src.spaget_count-- //this is fine, it doesn't need to be tick perfect
		else if(src.katamari_mode)
			var/obj/dummy/kat_overlay = new()
			kat_overlay.appearance = A.appearance
			kat_overlay.appearance_flags = RESET_COLOR | RESET_ALPHA | PIXEL_SCALE | RESET_TRANSFORM
			kat_overlay.pixel_x = 0
			kat_overlay.pixel_y = 0
			kat_overlay.vis_flags = 0
			kat_overlay.plane = PLANE_NOSHADOW_ABOVE
			kat_overlay.layer = src.layer + rand()
			kat_overlay.mouse_opacity = 0
			kat_overlay.alpha = 64
			var/matrix/tr = new
			tr.Turn(randfloat(0, 360))
			tr.Translate(sqrt(num_absorbed) * 3 + 16 - 16, -16)
			tr.Turn(randfloat(0, 360))
			tr.Translate(-pixel_x, -pixel_y)
			kat_overlay.transform = tr
			src.underlays += kat_overlay

	if (isliving(A) && !isintangible(A))//if its a mob
		var/mob/living/L = A
		L.set_loc(src.get_center())
		gain = 20
		if (ishuman(L))
			var/mob/living/carbon/human/H = A
			//Special halloween-time Unkillable gibspam protection!
			if (H.unkillable)
				H.unkillable = 0
			H.dump_contents_chance = 100 // zamu being funny here for the crunchy gib mode
			if (H.mind && H.mind.assigned_role)
				logTheThing(LOG_COMBAT, H, "is spaghettified by \the [src] at [log_loc(src)].")
				src.num_absorbed_players++
				switch (H.mind.assigned_role)
					if ("Clown")
						// Hilarious.
						gain = 500
						grow()
					if ("Lawyer")
						// Satan.
						gain = 250
					if ("Tourist", "Geneticist")
						// Nerds that are oblivious to dangers
						gain = 200
					if ("Chief Engineer")
						// Hubris
						gain = 150
					if ("Engineer")
						// More hubris
						gain = 100
					if ("Staff Assistant", "Captain")
						// Worthless
						gain = 20
					else
						gain = 50

		if (gib_mobs)
			// this also ghostize/qdels.
			L.gib()
		else
			L.ghostize()
			qdel(L)

	else if (isobj(A))
		//if (istype(A, /obj/item/graviton_grenade))
			//src.warp = 100
		if (istype(A.material))
			gain += A.material.getProperty("density") * 3 * A.material_amt
			gain += A.material.getProperty("radioactive") * 4 * A.material_amt
			gain += A.material.getProperty("n_radioactive") * 6 * A.material_amt
			if(isitem(A))
				var/obj/item/I = A
				gain *= min(I.amount, INFINITY)

		if (A.reagents)
			gain += min(A.reagents.total_volume/4, 50)

		if (istype(A, /obj/machinery/nuclearbomb))
			gain += 5000 //ten clowns
			playsound_global(clients, 'sound/machines/singulo_start.ogg', 50)
			SPAWN(1 SECOND)
				src.max_radius += 5
				for (var/i in 1 to 5)
					src.grow()
					sleep(0.5 SECONDS)
			qdel(A)
		else if (istype(A, /obj/item/plutonium_core)) // as a treat
			gain += 5000
			qdel(A)
		else
			var/obj/O = A
			src.succ_cache[A.type] += 1
			gain += 10/succ_cache[A.type]
			for(var/atom/other_food in A)
				src.consume_atom(other_food, no_visuals = TRUE)
			O.set_loc(src.get_center())
			O.ex_act(1)
			if (O)
				qdel(O)

	else if (isturf(A))
		var/turf/T = A
		if (issimulatedturf(T))
			if (istype(T, /turf/simulated/floor))
				T.ReplaceWithSpace()
				gain += 2
			else
				T.ReplaceWithFloor()

	src.stored_energy += gain

/obj/machinery/the_singularity/proc/get_center()
	return src.loc

/obj/machinery/the_singularity/attackby(var/obj/item/I, var/mob/user)
	if (istype(I, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/C = I
		if (!C.on)
			C.light(user, SPAN_ALERT("<b>[user]</b> lights [C] on [src]. Holy fucking shit!"))
		else
			return ..()
	else
		return ..()

/obj/machinery/the_singularity/proc/shrink()
	src.radius--
	SafeScaleAnim((src.radius-0.5)/(src.radius+0.5),(src.radius-0.5)/(src.radius+0.5), anim_time=3 SECONDS, anim_easing=CUBIC_EASING|EASE_OUT)
	src.gravity_pull_radius = min((src.radius+1)*3, src.gravity_pull_radius)

/obj/machinery/the_singularity/proc/grow()
	if (src.radius < src.max_radius)
		src.radius++
		SafeScaleAnim((src.radius+0.5)/(src.radius-0.5),(src.radius+0.5)/(src.radius-0.5), anim_time=3 SECONDS, anim_easing=CUBIC_EASING|EASE_OUT)
		src.gravity_pull_radius = max(src.gravity_pull_radius, src.radius)

// totally rewrote this proc from the ground-up because it was puke but I want to keep this comment down here vvv so we can bask in the glory of What Used To Be - haine
		/* uh why was lighting a cig causing the singularity to have an extra process()?
		   this is dumb as hell, commenting this. the cigarette will get processed very soon. -drsingh
		SPAWN(0) //start fires while it's lit
			src.process()
		*/

/////////////////////////////////////////////Controls which "event" is called
/obj/machinery/the_singularity/proc/event()
	var/numb = rand(1,3)
	if(prob(25 / max(src.radius, 1)))
		grow()
	switch (numb)
		if (1)//Eats the turfs around it
			BHolerip()
			return
		if (2)//tox damage all carbon mobs in area
			Toxmob()
			return
		if (3)//Stun mobs who lack optic scanners
			Mezzer()
			return

/obj/machinery/the_singularity/proc/Toxmob()
	for (var/mob/living/M in hearers(src.radius*EVENT_GROWTH+EVENT_MINIMUM, src.get_center()))
		M.take_radiation_dose(clamp(0.2 SIEVERTS*(src.radius+1), 0, 2 SIEVERTS))
		M.show_text("You feel odd.", "red")

/obj/machinery/the_singularity/proc/Mezzer()
	for (var/mob/living/carbon/M in hearers(src.radius*EVENT_GROWTH+EVENT_MINIMUM, src.get_center()))
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.bioHolder?.HasEffect("blind") || H.blinded)
				return
			else if (istype(H.glasses,/obj/item/clothing/glasses/toggleable/meson))
				M.show_text("You look directly into [src.name], good thing you had your protective eyewear on!", "green")
				return
			// remaining eye(s) meson cybereyes?
			else if((!H.organHolder?.left_eye || istype(H.organHolder?.left_eye, /obj/item/organ/eye/cyber/meson)) && (!H.organHolder?.right_eye || istype(H.organHolder?.right_eye, /obj/item/organ/eye/cyber/meson)))
				M.show_text("You look directly into [src.name], good thing your eyes are protected!", "green")
				return
		M.changeStatus("stunned", 7 SECONDS)
		M.visible_message(SPAN_ALERT("<B>[M] stares blankly at [src]!</B>"),\
		"<B>You look directly into [src]!<br>[SPAN_ALERT("You feel weak!")]</B>")

/obj/machinery/the_singularity/proc/BHolerip()
	var/turf/sing_center = src.get_center()
	for (var/turf/T in orange(src.radius+EVENT_GROWTH+0.5, sing_center))
		if (prob(70))
			continue

		if (T && !istype(T, /turf/space) && (IN_EUCLIDEAN_RANGE(sing_center, T, src.radius+EVENT_GROWTH+0.5)))
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
#endif

/// Singularity that can exist on restricted z levels
/obj/machinery/the_singularity/admin
	restricted_z_allowed = TRUE


/particles/singularity
	transform = list(1, 0, 0, 0,
	                 0, 1, 0, 0,
					 0, 0, 0, 1,
					 0, 0, 0, 1)
	width = 200
	height = 200
	spawning = 2
	count = 1000
	lifespan = 8
	fade = 10
	fadein = 8
	position = generator("circle", 200, 300, UNIFORM_RAND)
	gravity = list(0, 0, 0.05)
	velocity = list(0, 0, 0.4)
	friction = 0.2

