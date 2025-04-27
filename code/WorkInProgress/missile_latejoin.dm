#define MISSILE_SPAWN_MOVEDELAY 1
#define MISSILE_FLOORS_TO_STOP 4

/obj/arrival_missile
	name = "human capsule missile"
	desc = "A great way to deliver humans to a research station. Trust me."
	anchored = ANCHORED
	density = 0
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "arrival_missile"
	bound_width = 32
	bound_height = 64
	layer = 30
	event_handler_flags = IMMUNE_OCEAN_PUSH | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP
	dir = NORTH
	var/move_dir = NORTH
	var/moved_on_flooring = 0
	var/datum/effects/system/ion_trail_follow/ion_trail = null
	var/mob/passenger = null
	var/num_loops = 0 // how many times we missed 😰
	var/turf/target = null // if set this overrides default landing as is *the only place* where we can stop
	var/missile_z = Z_LEVEL_STATION

	New()
		..()
		src.ion_trail = new /datum/effects/system/ion_trail_follow()
		src.ion_trail.set_up(src)
		src.ion_trail.yoffset = 13

	disposing()
		ion_trail.stop()
		passenger = null
		var/turf/T = get_turf(src)
		for (var/atom/movable/A in src)
			A.set_loc(T)
		robogibs(T)
		moved_on_flooring = 0
		target = null
		..()

	// its fucking lunch time
	proc/lunch(atom/movable/sent, d=null)
		if (!(sent))
			return 0
		if(ismob(sent))
			passenger = sent
		else
			for(var/mob/M in sent)
				passenger = M
				break
		src.missile_z = src.z
		sent.set_loc(src)
		if(d)
			src.update_dir(d)
		passenger?.playsound_local_not_inworld('sound/effects/bamf.ogg', 100)
		sleep(0.1 SECONDS)
		passenger?.playsound_local_not_inworld('sound/effects/flameswoosh.ogg', 100)
		ion_trail.start()
		move_self()

	proc/update_dir(d)
		move_dir = d
		src.set_dir(d)
		src.transform = null
		if(d & (WEST | EAST))
			var/matrix/tr = src.transform.Turn(dir2angle(d))
			src.transform = tr.Translate(16, -16)
		if(d & (NORTH | SOUTH))
			src.bound_width = 32
			src.bound_height = 64
			src.ion_trail.yoffset = 13
		else
			src.bound_width = 64
			src.bound_height = 32
			src.ion_trail.yoffset = 0

	proc/on_loop()
		if(!src.passenger)
			return
		var/again = ""
		if(src.num_loops > 1)
			again = " again"
		boutput(src.passenger, SPAN_ALERT("Whew, it seems like the missile missed[again]. Recalibrating!"))

	proc/move_self()
		var/glide = 0

		while (moved_on_flooring <= MISSILE_FLOORS_TO_STOP)
			glide = (32 / MISSILE_SPAWN_MOVEDELAY) * world.tick_lag// * (world.tick_lag / CLIENTSIDE_TICK_LAG_SMOOTH)
			src.glide_size = glide
			src.animate_movement = SLIDE_STEPS
			passenger?.glide_size = glide
			passenger?.animate_movement = SYNC_STEPS
			var/old_loc = src.loc
			src.set_loc(get_step(src, src.move_dir))
			SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, old_loc, src.move_dir)
			if(!src.loc)
				src.num_loops += 1
				src.on_loop()
				var/centerx = world.maxx / 2
				var/centery = world.maxy / 2
				if(src.target)
					src.reset_to_aim_at(src.target)
				else switch(src.num_loops)
					if(1)
						src.reset_to_aim_at(locate(rand(centerx - 100, centerx + 100), rand(centery - 100, centery + 100), 1))
					if(2)
						src.reset_to_aim_at(locate(rand(centerx - 50, centerx + 50), rand(centery - 50, centery + 50), 1))
					if(3)
						src.reset_to_aim_at(pick(landmarks[LANDMARK_LATEJOIN]))
					else
						src.reset_to_random_pos()
			src.glide_size = glide
			src.animate_movement = SLIDE_STEPS
			passenger?.glide_size = glide
			passenger?.animate_movement = SYNC_STEPS
			sleep(MISSILE_SPAWN_MOVEDELAY)

			var/area/AR = get_area(src)
			var/turf/T = get_turf(src)
			var/area_check = istype(AR, /area/station) && !istype(AR, /area/station/solar) && !istype(AR, /area/station/engine/singcore)
			var/turf_check = istype(T, /turf/simulated/floor) && !T.density
			if (istype(AR, /area/pod_wars))
				AR = TRUE
				turf_check = !T.density
			if (!src.target && turf_check && area_check && !AR.teleport_blocked && T.z == missile_z)
				var/ok = TRUE
				for(var/atom/A in T)
					if(A.density)
						ok = FALSE
						break
				if(ok)
					moved_on_flooring++
			if(T == src.target)
				break
			if(T.z != missile_z)
				src.z = missile_z

		qdel(src)

	proc/reset_to_random_pos(dir=null)
		src.reset_to_aim_at(locate(rand(1, world.maxx), rand(1, world.maxy), 1), dir)

	proc/reset_to_aim_at(turf/target, new_dir=null)
		if(!new_dir)
			new_dir = pick(cardinal)
		src.update_dir(new_dir)
		var/turf/start = get_step(get_edge_target_turf(target, turn(dir, 180)), dir)
		src.set_loc(start)

proc/launch_with_missile(atom/movable/thing, turf/target, dir=null, missile_sprite, async=FALSE)
	var/obj/arrival_missile/missile = new /obj/arrival_missile
	if(missile_sprite)
		missile.icon_state = "[missile_sprite]"
	if(!target)
		missile.reset_to_random_pos()
	else
		missile.reset_to_aim_at(target, dir)
		missile.target = target

	if(async)
		SPAWN(0)
			missile.lunch(thing)
	else
		missile.lunch(thing)
	return missile

proc/latejoin_missile_spawn(var/mob/character)
	var/obj/arrival_missile/M = new /obj/arrival_missile
	var/turf/T = pick_landmark(LANDMARK_LATEJOIN_MISSILE)
	var/missile_dir = landmarks[LANDMARK_LATEJOIN_MISSILE][T]
	M.set_loc(T)
	SPAWN(0)
		M.lunch(character, missile_dir)
