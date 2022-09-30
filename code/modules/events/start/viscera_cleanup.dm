/datum/random_event/start/viscera
	name = "Viscera Cleanup"
	customization_available = 0
	required_elapsed_round_time = 0

	admin_call(var/source)
		if (..())
			return

	event_effect(var/source)
		..()

		var/list/turfs
		var/turf/T
		var/i

		turfs = get_area_turfs(/area/station/science/chemistry, TRUE)
		if(length(turfs))
			var/pools = rand(0,3)
			for(i in 1 to pools)
				T = pick(turfs)
				T.fluid_react_single(weighted_pick(list("lube"=10, "ash"=2, "fuel"=2)), rand(5,50))

		turfs = get_area_turfs(/area/station/science/testchamber, TRUE)
		if(length(turfs))
			for(i in 1 to rand(1,3))
				make_cleanable(/obj/decal/cleanable/blood,pick(turfs))
			for(i in 1 to rand(0,1))
				make_cleanable(/obj/decal/cleanable/ash,pick(turfs))
			if(prob(20))
				make_cleanable(/obj/decal/cleanable/blood/gibs,pick(turfs))
			if(prob(5))
				if(prob(80))
					gibs(pick(turfs))
				else
					partygibs(pick(turfs))

		turfs = get_area_turfs(/area/station/medical/medbay/surgery, TRUE)
		if(length(turfs))
			for(i in 1 to rand(1,5))
				make_cleanable(/obj/decal/cleanable/blood,pick(turfs))
			if(prob(85))
				T = pick(turfs)
				T.fluid_react_single("blood", rand(25,150))
			if(prob(5))
				gibs(pick(turfs))

		turfs = get_area_turfs(/area/station/medical/morgue, TRUE)
		if(length(turfs))
			for(i in 1 to rand(0,3))
				make_cleanable(/obj/decal/cleanable/dirt,pick(turfs))
			for(i in 1 to rand(0,3))
				make_cleanable(/obj/decal/cleanable/blood,pick(turfs))
			if(prob(15))
				make_cleanable(/obj/decal/cleanable/vomit,pick(turfs))
			if(prob(1))
				gibs(pick(turfs))

		turfs = get_area_turfs(/area/station/medical/robotics, TRUE)
		if(length(turfs))
			for(i in 1 to rand(0,3))
				make_cleanable(/obj/decal/cleanable/robot_debris,pick(turfs))
			for(i in 1 to rand(0,3))
				make_cleanable(/obj/decal/cleanable/oil,pick(turfs))
			if(prob(10))
				robogibs(pick(turfs))
			if(prob(5))
				gibs(pick(turfs))

		turfs = get_area_turfs(/area/station/security/brig, TRUE)
		if(length(turfs))
			if(prob(5))
				make_cleanable(/obj/decal/cleanable/vomit,pick(turfs))
			for(i in 1 to rand(0,2))
				make_cleanable(/obj/decal/cleanable/dirt,pick(turfs))
			if(prob(5))
				make_cleanable(/obj/decal/cleanable/urine,pick(turfs))
			if(prob(1))
				gibs(pick(turfs))

		turfs = get_area_turfs(/area/station/crew_quarters/kitchen, TRUE)
		if(length(turfs))
			for(i in 1 to rand(0,3))
				make_cleanable(/obj/decal/cleanable/ketchup,pick(turfs))
			for(i in 1 to rand(0,3))
				make_cleanable(/obj/decal/cleanable/blood,pick(turfs))
			if(prob(10))
				for(i in 1 to rand(1,3))
					make_cleanable(/obj/decal/cleanable/vomit,pick(turfs))
			if(prob(1))
				gibs(pick(turfs))

		turfs = get_area_turfs(/area/station/crew_quarters/catering, TRUE)
		if(length(turfs))
			for(i in 1 to rand(0,3))
				make_cleanable(/obj/decal/cleanable/blood,pick(turfs))
			for(i in 1 to rand(0,3))
				make_cleanable(/obj/decal/cleanable/dirt,pick(turfs))
			if(prob(25))
				gibs(pick(turfs))


		turfs = get_area_turfs(/area/station/crew_quarters/cafeteria, TRUE)
		if(length(turfs))
			for(i in 1 to rand(0,3))
				make_cleanable(/obj/decal/cleanable/blood,pick(turfs))
			for(i in 1 to rand(0,3))
				make_cleanable(/obj/decal/cleanable/urine,pick(turfs))
			for(i in 1 to rand(0,3))
				make_cleanable(/obj/decal/cleanable/water,pick(turfs))
			for(i in 1 to rand(0,4))
				make_cleanable(/obj/decal/cleanable/dirt,pick(turfs))

			for(i in 1 to rand(0,6))
				if(prob(20))
					new /obj/item/cigbutt(pick(turfs))
				else if(prob(20))
					new /obj/item/raw_material/shard/glass(pick(turfs))

		for(i in 1 to rand(0,4))
			T = get_random_station_turf()
			gibs(T)

		for(i in 1 to rand(0,3))
			T = get_random_station_turf()
			robogibs(T)

		for(i in 1 to rand(0,30))
			T = get_random_station_turf()
			make_cleanable(/obj/decal/cleanable/dirt,T)

		for(i in 1 to rand(0,3))
			var/item = weighted_pick(list(/obj/item/casing = 10, /obj/item/casing/rifle = 2, /obj/item/casing/small = 5))
			T = get_random_station_turf()
			new item(T)

		for(i in 1 to rand(4,20))
			var/obj/machinery/light/L = pick(stationLights)
			L.broken(TRUE)

		var/list/area/stationAreas = get_accessible_station_areas()
		var/obj/machinery/light_switch/S
		for(i in 1 to rand(0,5))
			var/area/SA = stationAreas[pick(stationAreas)]
			S = locate(/obj/machinery/light_switch) in SA?.machines
			if(istype(S))
				S.Attackhand(null)



