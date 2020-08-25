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
	proc/lunch(var/mob/living/person, var/d = NORTH)
		if (!(person))
			return 0
		passenger = person
		person.set_loc(src)
		move_dir = d
		dir = d
		passenger << 'sound/effects/bamf.ogg'
		//playsound(src.loc, "sound/effects/bamf.ogg", 100, 0)
		sleep(0.1 SECONDS)
		passenger << 'sound/effects/flameswoosh.ogg'
		//playsound(src.loc, "sound/effects/flameswoosh.ogg", 100, 0)
		ion_trail.start()
		move_self()

	proc/move_self()
		var/glide = 0

		while (moved_on_flooring <= 4)
			glide = (32 / MISSILE_SPAWN_MOVEDELAY) * world.tick_lag// * (world.tick_lag / CLIENTSIDE_TICK_LAG_SMOOTH)
			src.glide_size = glide
			src.animate_movement = SLIDE_STEPS
			passenger.glide_size = glide
			passenger.animate_movement = SYNC_STEPS
			//step(src,NORTH)
			src.y++
			src.glide_size = glide
			src.animate_movement = SLIDE_STEPS
			passenger.glide_size = glide
			passenger.animate_movement = SYNC_STEPS
			sleep(MISSILE_SPAWN_MOVEDELAY)

			if (istype(get_turf(src), /turf/simulated/floor) && get_area(src))
				moved_on_flooring++

		pool(src)


