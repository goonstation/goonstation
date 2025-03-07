
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
	var/do_light_gen = 1

	proc/handle_light_generating_turfs(lagcheck_at = LAG_REALTIME)
		if (do_light_gen)
			for (var/_F in by_cat[TR_CAT_LIGHT_GENERATING_TURFS])
				var/turf/space/fluid/F = _F
				F.make_light()
				LAGCHECK(lagcheck_at)

			if(TR_CAT_LIGHT_GENERATING_TURFS in by_cat)
				by_cat[TR_CAT_LIGHT_GENERATING_TURFS].len = 0

		/*
		for (var/turf/space/fluid/F in light_generating_fluid_turfs)
			var/bordering = 0
			for (var/dir in cardinal)
				var/turf/T = get_step(F,dir)
				if(IS_VALID_FLUID_TURF(T) && !FLUID_SPAWNER_TURF_BLOCKED(T))
					if (!(F in processing_fluid_turfs))
						src.processing_fluid_turfs.Add(F)
				if (!istype(T,/turf/space))
					bordering = 1
			if (bordering && !F.light)
				F.make_light()
			LAGCHECK(LAG_REALTIME)
		light_generating_fluid_turfs.len = 0*/

	setup()
		name = "Fluid_Turfs"
		schedule_interval = 5 SECONDS

		src.processing_fluid_turfs = global.processing_fluid_turfs

		SPAWN(20 SECONDS)
			if (total_clients() >= OSHAN_LIGHT_OVERLOAD)
				do_light_gen = 0

			handle_light_generating_turfs(90)

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/fluid_turfs/old_fluid_turfs = target
		src.processing_fluid_turfs = old_fluid_turfs.processing_fluid_turfs

	doWork()
		var/adjacent_space = 0
		var/adjacent_block = 0
		var/turf/t

		handle_light_generating_turfs()

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

			if (adjacent_space >= 4)
				if (T.light)
					T.light.disable()

			if (adjacent_space + adjacent_block >= 4)
				processing_fluid_turfs.Remove(T)
