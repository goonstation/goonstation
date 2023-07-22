/*
PLANET CRASH EVENT
 */

/*
Process:
- Delay event start until 5 minutes in, begin with centcom announcement regarding failing retrothrusters or whatever
- Delay 1 minute
- Start upper atmosphere space tile changes (dark blue, up from south edge of map)
- Once upper atmos tile changes reach halfway up the z-level
	- Centcom alert about increasing heat
	- Show faded/small heat effect on south-facing exterior tiles (increase opacity/size of effect each loop)
	- Increase ambient temperature of southern station areas slightly
- Once upper atmos tiles changes reach 75% up z-level, start lower-upper tile changes (lighter blue)
- Loop this process of increasing alerts/heat effects/ambient heat for specified quantity of atmos tile changes (dark blue to light blue)
- Once halfway through tile change loop
	- Burn off all solar arrays
	- Begin random fireflash events across the station
- At event completion, show 5-10 second "cinematic" (similar to nuke-op success state) showing the station crashing into the ocean

Notes:
- Ambient temperature should reach life-threatening/spontaneous combustion levels about 1-2 minutes before event end
- Sprinkle in screen shake events at certain intervals to simulate a rough atmospheric entry
- Tile changes should operate on a generous lag_check loop to avoid performance hits. This has the secondary effect of having each tile change take a bit of time to occur.
- Centcom announcements should increase in panic over time.
- Look into ways to handle people exiting the station during the event (ideally to make them fuckin' combust if they dare a space walk during atmospheric entry)
 */

//#define PLANET_CRASH_ENABLED 1

#ifdef PLANET_CRASH_ENABLED

/datum/planetCrash
	/*
	var/list/events = new()


	// Kick off the event!
	proc/start()
		// send centcom message
		// begin timer for first sub-event


	// Change space to a certain atmosphere color tile, progressively up from the southern map edge
	proc/showAtmosTiles(atmosColor = null)
		for (var/row = 1, row <= world.maxy, row++) // Each map row from bottom
			for (var/col = 1, col <= world.maxx, col++) // Each column (tile) within this row
				// apply tile change


	// Show a heatshield burning effect on southern facing exterior tiles of the station
	proc/setHeatshieldBurn(burnAmount = null)
		//


	proc/setAmbientTemperature(temp = null)
		//
	*/

	proc/getController()
		for (var/datum/controller/process/planetCrash/C in processScheduler.processes)
			return C
		return null


/datum/planetCrashEvent
	proc/start()
		return


/datum/controller/process/planetCrash
	var/list/hotspots = list()

	setup()
		name = "Planet Crash"
		schedule_interval = 41

	doWork()
		for (var/datum/planetCrashHotspot/H in src.hotspots)
			H.process()
			scheck()


/datum/planetCrashHotspot
	var/turf/simulated/spot
	var/tempTarget = 373 //100c
	var/heatAmount = 5.2

	New(turf/simulated/spot)
		src.spot = spot

		var/datum/controller/process/planetCrash/C = planetCrash.getController()
		C.hotspots += src

	proc/process()
		var/datum/gas_mixture/env = src.spot.remove_air(TOTAL_MOLES(src.spot.air))
		if (env)
			out(world, "Current temp: [env.temperature]")
			env.temperature += src.heatAmount
			env.react()
			src.spot.assume_air(env)
			out(world, "New temp: [env.temperature]")

		/*
		if (istype(src.spot))
			out(world, "Operating on [src.spot]")
			var/datum/gas_mixture/env = src.spot.return_air()
			if (env.temperature < src.tempTarget)
				var/transfer_moles = TOTAL_MOLES(env)
				var/datum/gas_mixture/removed = env.remove(transfer_moles)
				out(world, "got [transfer_moles] moles at [removed.temperature]")

				if (removed)
					/*
					var/heat_capacity = HEAT_CAPACITY(removed)
					out(world, "heating ([heat_capacity])")
					if (heat_capacity)
						removed.temperature = (removed.temperature*heat_capacity + src.heatAmount)/heat_capacity
					*/

					removed.temperature += src.heatAmount
					out(world, "now at [removed.temperature]")
				env.merge(removed)
				out(world, "turf now at [env.temperature]")
		*/


var/datum/planetCrash/planetCrash = new()

var/datum/planetCrashHotspot/hotspotTest

// TODO: Debug verb, remove
/client/verb/testPlanetCrash()
	set name = "Test Planet Crash"
	//new /datum/planetCrashHotspot(get_turf(src.mob))
	hotspotTest = new(get_turf(src.mob))
	out(world, "Done supposedly")

// TODO: Debug verb, remove
/client/verb/testPlanetCrash2(var/amount as num)
	set name = "Test Planet Crash 2"
	hotspotTest.heatAmount = amount
	out(world, "Done supposedly")

#endif
