/datum/controller/process/bubble_vents
	setup()
		name = "Bubble vents"
		schedule_interval = 3 SECONDS
#ifdef MAP_OVERRIDE_NEON
		for (var/i in 1 to 7)
			var/turf/T = null
			while (!istype(T, /turf/space/fluid))
				T = locate(rand(1, world.maxx), rand(1, world.maxy), Z_LEVEL_STATION)
			var/obj/bubble_vent/new_vent = new(T)
			var/list/gases = list()
#define _LIST_GASES(GAS, ...) gases += #GAS;
			APPLY_TO_GASES(_LIST_GASES)
#undef _LIST_GASES
			var/number_of_gases = pick(prob(300);1, prob(50);2, prob(10);3)
			for (var/gas_num in 1 to number_of_gases)
				var/chosen_gas = pick(gases)
				//I know how this looks BUT it's technically compile time safe because of the above macro
				//I can't do the entire thing in macros because we need to pick() our gases
				new_vent.vars[chosen_gas] = TRUE
				gases -= chosen_gas
#endif

	doWork()
		for_by_tcl(bubble_vent, /obj/bubble_vent)
			bubble_vent.process()
