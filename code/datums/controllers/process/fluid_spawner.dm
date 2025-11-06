
#define FLUID_SPAWNER_TURF_BLOCKED(t) (!t || (t.active_liquid && t.active_liquid.group && t.active_liquid.group.amt_per_tile >= 300) || !t.ocean_canpass())

#ifdef MAP_OVERRIDE_NADIR
var/global/ocean_reagent_id = "tene"
#else
var/global/ocean_reagent_id = "water"
#endif

var/global/ocean_name = "ocean"
var/global/datum/color/ocean_color = 0
var/global/obj/fluid/ocean_fluid_obj = null

/// Processes fluid turfs
/datum/controller/process/fluid_turfs
	var/tmp/list/processing_fluid_turfs
	var/add_reagent_amount = 500

	setup()
		name = "Fluid_Turfs"
		schedule_interval = 5 SECONDS

		src.processing_fluid_turfs = global.processing_fluid_turfs

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/fluid_turfs/old_fluid_turfs = target
		src.processing_fluid_turfs = old_fluid_turfs.processing_fluid_turfs

	doWork()
		var/adjacent_space = 0
		var/adjacent_block = 0
		var/turf/t

		for (var/turf/space/fluid/T in processing_fluid_turfs)
			if (!T || !T.ocean_canpass()) continue
			adjacent_space = 0
			adjacent_block = 0
			for (var/dir in cardinal)

				LAGCHECK(LAG_HIGH)

				t = get_step(T,dir)

				if (istype(t, /turf/space))
					adjacent_space += 1
					continue

				if (FLUID_SPAWNER_TURF_BLOCKED(t))
					adjacent_block += 1
					continue

				if (t.active_liquid && t.active_liquid.group)
					t.active_liquid.group.reagents.add_reagent(ocean_reagent_id,add_reagent_amount)
					t.active_liquid.group.update_loop()
				else
					var/obj/fluid/F = t.fluid_react_single(ocean_reagent_id, add_reagent_amount)
					if (F)
						F.last_depth_level = 3 //lol hardcode for ocean depth when a new puddle forms
						F.group.last_depth_level = 3

			if (adjacent_space + adjacent_block >= 4)
				processing_fluid_turfs.Remove(T)
