/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optinally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////
/datum/effects/system/mustard_gas_spread
	var/number = 3
	var/spread_cardinal = FALSE
	var/turf/location
	var/atom/holder
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effects/system/mustard_gas_spread/proc/set_up(number = 5, spread_cardinal = FALSE, location, dir)
	if(number > 20)
		number = 20
	src.number = number
	src.spread_cardinal = spread_cardinal
	if(isturf(location))
		src.location = location
	else
		src.location = get_turf(location)
	if(dir)
		direction = dir

/datum/effects/system/mustard_gas_spread/proc/attach(atom/A)
	holder = A

/datum/effects/system/mustard_gas_spread/proc/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		SPAWN(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effects/mustard_gas/smoke = new /obj/effects/mustard_gas(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.spread_cardinal)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(1 SECOND)
				step(smoke,direction)
			sleep(10 SECONDS)
			qdel(smoke)
			src.total_smoke--
