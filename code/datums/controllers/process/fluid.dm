/// Controller for fluids
/datum/controller/process/fluid_group
	var/tmp/list/processing_fluid_groups = list()
	var/tmp/list/processing_fluid_spreads = list()
	var/tmp/list/processing_fluid_drains = list()

	var/group_update_interval = 40 SECONDS
	var/last_group_update = 0

	var/max_schedule_interval = 4 SECONDS
	var/min_schedule_interval = 0.5 SECONDS

	setup()
		name = "Fluid_Groups"
		schedule_interval = max_schedule_interval

		src.processing_fluid_groups = global.processing_fluid_groups
		src.processing_fluid_spreads = global.processing_fluid_spreads
		src.processing_fluid_drains = global.processing_fluid_drains

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/fluid_group/old_fluids = target
		src.processing_fluid_drains = old_fluids.processing_fluid_drains
		src.processing_fluid_groups = old_fluids.processing_fluid_groups
		src.processing_fluid_spreads = old_fluids.processing_fluid_spreads

	doWork()

		///////////////////
		//process dranes //
		///////////////////

		for (var/datum/fluid_group/FG in processing_fluid_drains)
			LAGCHECK(LAG_LOW)
			if (QDELETED(FG)) continue

			if (FG.queued_drains)
				FG.reagents.skip_next_update = 1
				FG.drain(FG.last_drain.active_liquid ? FG.last_drain.active_liquid : pick(FG.members), FG.queued_drains) //420 drain it
				if(QDELETED(FG))
					continue
				FG.queued_drains = 0
				FG.last_drain = 0
				FG.draining = 0
				processing_fluid_drains.Remove(FG)

				if (FG.qdeled)
					FG = null

		///////////////////
		//process spreads//
		///////////////////

		var/avg_viscosity = 0
		for (var/datum/fluid_group/FG in processing_fluid_spreads)
			if (world.time < FG.last_update_time + FG.avg_viscosity) continue
			LAGCHECK(LAG_LOW)
			if (QDELETED(FG)) continue

			FG.last_update_time = world.time
			if (FG.update_once())
				processing_fluid_spreads.Remove(FG)
			else if (FG)
				avg_viscosity += FG.avg_viscosity

			if (FG?.qdeled)
				FG = null

		avg_viscosity /= processing_fluid_spreads.len ? processing_fluid_spreads.len : 1

		if (avg_viscosity <= 0)
			schedule_interval = max_schedule_interval
		else
			//mbc why am help me
			if (main.last_run_time[src] > 5)
				min_schedule_interval = 10
				if (main.last_run_time[src] > 13)
					min_schedule_interval = 26
					if (main.last_run_time[src] > 20)
						min_schedule_interval = max_schedule_interval
			else
				min_schedule_interval = 5

			schedule_interval = max(min_schedule_interval, avg_viscosity)



		///////////////////////////////////////////////////////////////////////
		//if interval time has passed, do evaporation + temperature processing/
		///////////////////////////////////////////////////////////////////////
		if (world.time > src.last_group_update + src.group_update_interval)
			src.last_group_update = world.time
			var/atom/selected_temp_expose = 0
			for (var/datum/fluid_group/FG in processing_fluid_groups)
				LAGCHECK(LAG_MED)
				if (QDELETED(FG)) continue
				if (!FG.members || !length(FG.members)) continue

				//temperature stuff

				selected_temp_expose = pick(FG.members)
				if (!selected_temp_expose)
					continue
				var/turf/T = selected_temp_expose.loc //lollllllllllll
				var/target_temp = T20C
				if (istype(T))
					target_temp = T.temperature

				var/difference = (target_temp - FG.reagents.total_temperature)
				var/change = difference * 0.3 //absorb 30% of the ambient temperature every update

				FG.reagents.set_reagent_temp(FG.reagents.total_temperature + change , 1)

				//blahh i dont wannaaaa loop thru members. It's more accurate of a temperature read, but I would rather skip the loop for SPEED0
				/*
				for (var/obj/fluid/F in FG.members)
					LAGCHECK(LAG_LOW)
					if (!F || F.pooled || !F.reagents) continue
					var/turf/T = F.loc
					var/target_temp = T20C
					if (istype(T))
						target_temp = T.temperature

					var/difference = (target_temp - F.reagents.total_temperature)
					var/change = difference * 0.6 //absorb 60% of the ambient temperature every update

					F.reagents.set_reagent_temp(F.reagents.total_temperature + change , 1)
				*/
				LAGCHECK(LAG_MED)
				if (QDELETED(FG)) continue
				//evaporate stuff
				if (FG.amt_per_tile <= FG.required_to_spread && !FG.updating)
					avg_viscosity = FG.avg_viscosity
					avg_viscosity = (FG.avg_viscosity-1) / (FG.max_viscosity-1) // should range from 0 to 1 now

					if ( world.time - FG.last_add_time > (FG.base_evaporation_time + (FG.bonus_evaporation_time * avg_viscosity)) )

						//blood shouldn't evaporate cause its evidence. Just create decals.
						if (FG.reagents.get_master_reagent_name() == "blood")
							for (var/obj/fluid/F in FG.members)
								LAGCHECK(LAG_MED)
								if (QDELETED(F)) continue
								var/obj/decal/cleanable/blood/dynamic/B = make_cleanable(/obj/decal/cleanable/blood/dynamic,F.loc)
								B.sample_reagent = "blood"
								B.add_volume(F.color, do_fluid_react = 0)
								B.handle_reagent_list(FG.reagents.reagent_list)
								B.blood_DNA = F.blood_DNA
								B.blood_type = F.blood_type

						FG.evaporate()
						if (FG?.qdeled)
							FG = null
