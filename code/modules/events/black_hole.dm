/datum/random_event/major/black_hole
	name = "Black Hole"
	required_elapsed_round_time = 26.6 MINUTES
#ifdef RP_MODE
	disabled = 1
#endif

	event_effect(var/source,var/turf/T,var/delay,var/duration)
		..()

		if (!istype(T,/turf/))
			T = pick_landmark(LANDMARK_BLOBSTART)
			if(!T)
				message_admins("The black hole event failed to spawn a black hole (no blobstart landmark found)")
				return

		message_admins("Black Hole anomaly spawning in [T.loc]")
		new /obj/anomaly/bhole_spawner(T,3 MINUTES)

/obj/anomaly/bhole_spawner
	name = "dark anomaly"
	desc = "Looking at this anomaly hurts your eyes, as if the darkness it emits is somehow too bright to stand."
	icon = 'icons/obj/anomalies.dmi'
	icon_state = "space_tear"
	density = 1
	var/feedings = 0
	var/feedings_required = 0
	var/stable = 0

	New(var/loc,var/lifespan = 2.5 MINUTES)
		..()
		feedings_required = rand(15,40)
		//spatial interdictor: can't stop the black hole, but it can mitigate it
		//interdiction consumes several thousand units - requiring a large cell - and the interdictor makes a hell of a ruckus
		for (var/obj/machinery/interdictor/IX in by_type[/obj/machinery/interdictor])
			if (IN_RANGE(IX,src,IX.interdict_range) && IX.expend_interdict(9001))
				playsound(IX,'sound/machines/alarm_a.ogg',50,0,5,1.5)
				SPAWN(3 SECONDS)
					if(IX) playsound(IX,'sound/machines/alarm_a.ogg',50,0,5,1.5)
				IX.visible_message("<span class='alert'><b>[IX] emits a gravitational anomaly warning!</b></span>")
				feedings_required = rand(12,24)
				lifespan = lifespan * 1.2
				break

		if(!particleMaster.CheckSystemExists(/datum/particleSystem/bhole_warning, src))
			particleMaster.SpawnSystem(new /datum/particleSystem/bhole_warning(src))

		var/turf/T = get_turf(src)
		for (var/mob/M in GET_NEARBY(T, 15))
			if (M.client)
				boutput(M, "<span class='alert'>The air grows heavy and thick. Something feels terribly wrong.</span>")
				shake_camera(M, 5, 16)
		playsound(src,'sound/effects/creaking_metal1.ogg',100,0,5,0.5)

		sleep(lifespan / 2)
		if (!stable)
			src.visible_message("<span class='alert'><b>[src] begins to collapse in on itself!</b></span>")
			playsound(src,'sound/machines/engine_alert3.ogg',100,0,5,0.5)
			animate(src, transform = matrix(4, MATRIX_SCALE), time = 300, loop = 0, easing = LINEAR_EASING)
		if (random_events.announce_events)
			command_alert("A severe gravitational anomaly has been detected on the [station_or_ship()] in [get_area(src)]. It may collapse into a black hole if not stabilized. All personnel should feed mass to the anomaly until it stabilizes.", "Gravitational Anomaly", alert_origin = ALERT_ANOMALY)

		sleep(lifespan)
		if (!stable)
			src.visible_message("<span class='alert'><b>[src] collapses into a black hole!</b></span>")
			playsound(src, 'sound/machines/singulo_start.ogg', 90, 0, 5)
			new /obj/bhole(get_turf(src),300,12)
		else
			src.visible_message("<span class='alert'><b>[src]</b> dissipates quietly into nothing.</span>")

		SPAWN(0)
			qdel(src)
		return

	Bumped(atom/A)
		if (!src.stable)
			if (istype(A,/obj/))
				if (isitem(A) || istype(A,/obj/projectile/)) src.get_fed(1)
				else src.get_fed(5)
				qdel(A)
			else if (isliving(A))
				var/mob/living/L = A
				logTheThing(LOG_COMBAT, L, "was elecgibbed by [src] ([src.type]) at [log_loc(L)].")
				L.elecgib()
				src.get_fed(10)

	disposing()
		if(particleMaster.CheckSystemExists(/datum/particleSystem/bhole_warning, src))
			particleMaster.RemoveSystem(/datum/particleSystem/bhole_warning)
		..()

	proc/get_fed(var/feed_amount)
		if (src.stable == 1 || !isnum(feed_amount) || feed_amount < 1)
			return
		src.feedings += feed_amount
		if (src.feedings >= src.feedings_required)
			src.stable = 1
			src.visible_message("<span class='notice'><b>[src] stabilizes and begins to harmlessly dissipate!</b></span>")
			src.name = "stabilized dark anomaly"
			src.desc = "This anomaly seems much calmer than it used to be. That's probably a good thing."
			// letting it dispose of itself in its new proc in case we can do research on it later or something

/obj/bhole
	name = "black hole"
	icon = 'icons/effects/160x160.dmi'
	desc = "FUCK FUCK FUCK AAAHHH"
	icon_state = "bhole"
	opacity = 0
	density = 0
	anchored = 1
	pixel_x = -64
	pixel_y = -64
	event_handler_flags = IMMUNE_SINGULARITY
	var/move_prob = 12
	var/time_to_die = 0

	New(var/loc,duration, move_prob = -1)
		..()
		if (duration < 1)
			duration = rand(5 SECONDS,30 SECONDS)

		if(move_prob > -1 )
			src.move_prob = move_prob

		time_to_die = ( ticker ? ticker.round_elapsed_ticks : 0 ) + duration

		processing_items |= src

	disposing()
		processing_items.Remove(src)
		..()

	Bumped(atom/A)
		if (isliving(A))
			logTheThing(LOG_COMBAT, A, "was gibbed by [src] ([src.type]) at [log_loc(A)].")
			A:gib()
		else if(isobj(A))
			var/obj/O = A
			O.ex_act(1)
			if(O)
				qdel(O)

	proc/process()
		var/turf/checkTurf = get_turf(src)
		if (time_to_die < ticker.round_elapsed_ticks || isrestrictedz(checkTurf?.z))
			qdel(src)
			return

		for (var/atom/X in range(7,src))
			if (X.event_handler_flags & IMMUNE_SINGULARITY)
				continue
			var/area/A = get_area(X)
			if(A?.sanctuary) continue
			if(isobj(X))
				var/obj/O = X
				if(O.anchored == 2) continue
				var/pull_prob = 0
				var/hit_strength = 0
				var/distance = GET_DIST(src,O)
				switch(distance)
					if (-INFINITY to 0)
						src.Bumped(O)
						continue
					if (1 to 2)
						pull_prob = 100
						hit_strength = 1
					if (3 to 4)
						pull_prob = 75
						hit_strength = 2
					if (5 to 6)
						pull_prob = 50
						hit_strength = 3
					if (6 to 7)
						pull_prob = 25

				if (O.anchored)
					if (prob(pull_prob))
						O.anchored = 0
				if (prob(pull_prob))
					step_towards(O,src)
					if (hit_strength)
						O.ex_act(hit_strength)

			if (ismob(X))
				var/mob/M = X
				step_towards(M,src)
				if (GET_DIST(src, M) <= 0)
					src.Bumped(M)

			if (isturf(X))
				var/turf/T = X
				var/shred_prob = 0
				var/distance = GET_DIST(src,T)
				switch(distance)
					if (-INFINITY to 0)
						T.ReplaceWithSpace()
					if (1 to 3)
						shred_prob = 90
					if (4 to 6)
						shred_prob = 40
					if (6 to 7)
						shred_prob = 10
				if (prob(shred_prob))
					shred_terrain(T)

			LAGCHECK(LAG_LOW)

		if(prob(move_prob))
			step(src,pick(cardinal))

	proc/shred_terrain(var/turf/simulated/T)
		if (!T)
			return

		if(istype(T,/turf/simulated/floor))
			var/turf/simulated/floor/F = T
			if(!F.broken)
				if(prob(80))
					var/obj/item/tile/TILE = new /obj/item/tile(F)
					if (F.material)
						TILE.setMaterial(F.material)
					else
						var/datum/material/M = getMaterial("steel")
						TILE.setMaterial(M)
					F.break_tile_to_plating(1)
				else
					F.break_tile(1)
			else
				F.ReplaceWithSpace()

		else if (istype(T,/turf/simulated/wall))
			var/atom/A = new /obj/structure/girder/reinforced(T)

			var/atom/movable/B = new /obj/item/raw_material/scrap_metal
			B.set_loc(T)

			if(T.material)
				A.setMaterial(T.material)
				B.setMaterial(T.material)
			else
				var/datum/material/M = getMaterial("steel")
				A.setMaterial(M)
				B.setMaterial(M)

			T.ReplaceWithFloor()

		else
			return

// Particle FX

/datum/particleSystem/bhole_warning
	New(var/atom/location = null)
		..(location, "bhole_warning", 300)

	Run()
		if (..())
			for(var/i=0, i<10, i++)
				sleep(rand(3,6))
				SpawnParticle()
			state = 1

/datum/particleType/bhole_warning
	name = "bhole_warning"
	icon = 'icons/effects/particles.dmi'
	icon_state = "32x32circle"

	MatrixInit()
		first = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.pixel_x += rand(-128,128)
			par.pixel_y += rand(-128,128)
			par.color = "#000000"
			par.alpha = 10

			first.Scale(0.1,0.1)
			par.transform = first

			first.Scale(50)
			animate(par, transform = first, time = 15 SECONDS, alpha = 30)

			first.Scale(0.1 / 50)
			animate(transform = first, time = 15 SECONDS, alpha = 5)
			first.Reset()
