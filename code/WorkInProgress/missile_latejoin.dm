#define MISSILE_SPAWN_MOVEDELAY 1

/obj/arrival_missile
	name = "human capsule missile"
	desc = "A great way to deliver humans to a research station. Trust me."
	anchored = 1
	density = 0
	icon = 'icons/obj/32x64.dmi'
	icon_state = "arrival_missile"
	bound_width = 32
	bound_height = 64
	layer = 30
	dir = NORTH
	var/move_dir = NORTH
	var/moved_on_flooring = 0
	var/datum/effects/system/ion_trail_follow/ion_trail = null
	var/mob/passenger = null
	New()
		..()
		src.ion_trail = new /datum/effects/system/ion_trail_follow()
		src.ion_trail.set_up(src)
		src.ion_trail.yoffset = 13

	unpooled()
		moved_on_flooring = 0
		..()

	pooled()
		ion_trail.stop()
		passenger = null
		var/turf/T = get_turf(src)
		for (var/atom/movable/A in src)
			A.set_loc(T)
		robogibs(T)
		moved_on_flooring = 0
		..()

	//disposing()
	//	ion_trail = null
	//	passenger = null
	//	..()

	// its fucking lunch time
	proc/lunch(mob/living/person, d=null)
		if (!(person))
			return 0
		passenger = person
		person.set_loc(src)
		if(d)
			src.set_dir(d)
		passenger << 'sound/effects/bamf.ogg'
		sleep(0.1 SECONDS)
		passenger << 'sound/effects/flameswoosh.ogg'
		//playsound(src.loc, "sound/effects/flameswoosh.ogg", 100, 0)
		ion_trail.start()
		move_self()

	proc/set_dir(d)
		move_dir = d
		dir = d
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

	proc/move_self()
		var/glide = 0

		while (moved_on_flooring <= 4)
			glide = (32 / MISSILE_SPAWN_MOVEDELAY) * world.tick_lag// * (world.tick_lag / CLIENTSIDE_TICK_LAG_SMOOTH)
			src.glide_size = glide
			src.animate_movement = SLIDE_STEPS
			passenger.glide_size = glide
			passenger.animate_movement = SYNC_STEPS
			src.loc = get_step(src, src.move_dir) // I think this is supposed to be loc= and not set_loc, not sure
			if(!src.loc)
				src.reset_to_random_pos()
			src.glide_size = glide
			src.animate_movement = SLIDE_STEPS
			passenger.glide_size = glide
			passenger.animate_movement = SYNC_STEPS
			sleep(MISSILE_SPAWN_MOVEDELAY)

			var/area/AR = get_area(src)
			if (istype(get_turf(src), /turf/simulated/floor) && !AR.teleport_blocked)
				moved_on_flooring++

		pool(src)

	proc/reset_to_random_pos()
		var/dir = pick(cardinal)
		src.set_dir(dir)
		var/turf/start = locate(rand(1, world.maxx), rand(1, world.maxy), 1)
		start = get_edge_target_turf(start, turn(dir, 180))
		src.set_loc(start)
