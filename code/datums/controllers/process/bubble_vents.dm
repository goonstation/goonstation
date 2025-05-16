/datum/controller/process/bubble_vents
	setup()
		name = "Bubble vents"
		schedule_interval = 3 SECONDS
#ifdef MAP_OVERRIDE_NEON
		while (length(by_type[/obj/bubble_vent]) < 10)
			var/turf/T = null
			while (!T || !istype_exact(T, /turf/space/fluid))
				T = locate(rand(1, world.maxx), rand(1, world.maxy), Z_LEVEL_STATION)
			if (!istype(get_area(T), /area/space/plasma_reef) && prob(70)) //to make them more common in reefs
				continue
			var/vent_type = pick(\
				prob(150); /obj/bubble_vent/plasma,\
				prob(100);/obj/bubble_vent/oxygen,\
				prob(50);/obj/bubble_vent/oxygen_b,\
				prob(50);/obj/bubble_vent/methane,\
				prob(20);/obj/bubble_vent/sleepy,\
			)
			var/obj/bubble_vent/new_vent = new vent_type(T)
			new_vent.temperature = rand(T0C - 10, T0C + 300)
#endif

	doWork()
		for_by_tcl(bubble_vent, /obj/bubble_vent)
			bubble_vent.process()
