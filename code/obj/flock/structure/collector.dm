/// # Collector structure
/obj/flock_structure/collector
	name = "Some weird lookin' pulsing thing"
	desc = "Seems to be pulsing."
	flock_id = "Collector"
	health = 60
	/// does it draw from the local apc if its strong enough.
	var/drawfromgrid = 0
	/// is it active?
	var/active = 0
	/// max range for the thing.
	var/maxrange = 5
	/// the tiles its connected to
	var/list/turf/simulated/floor/feather/connectedto = list()

	event_handler_flags = USE_CANPASS //needed for passthrough
	// drones can pass through this, might change this later, as balance point
	passthrough = TRUE

	poweruse = 0
	usesgroups = TRUE
	icon_state = "collector"

/obj/flock_structure/collector/New(var/atom/location, var/datum/flock/F=null)
	..(location, F)

/obj/flock_structure/collector/building_specific_info()
	return {"<span class='bold'>Connections:</span> Currently Connected to [length(connectedto)] tile[length(connectedto) == 1 ? "" : "s"].
	<br><span class='bold'>Power generation:</span> Currently generating [abs(poweruse)]."}

/obj/flock_structure/collector/process()
	..()
	calcconnected()
	if(length(connectedto))
		icon_state = "collectoron"
	else
		icon_state = "collector"
	src.poweruse = ((length(connectedto) * 5) / -1) //(5 power per tile)

/obj/flock_structure/collector/disposing()
	for(var/turf/simulated/floor/feather/flocktile as anything in connectedto)
		flocktile.off()
	connectedto.len = 0
	..()

/obj/flock_structure/collector/proc/calcconnected()
	for(var/turf/simulated/floor/feather/flocktile as anything in connectedto)
		flocktile.off()
		flocktile.connected = 0
	connectedto.len = 0
	var/myturf = get_turf(src)
	var/distance = 0 //how far has it gone already?
	var/turf/simulated/floor/feather/floor = myturf
	if(!istype(floor)) return//if it aint a flock floor

	if(floor.broken) return
	connectedto += myturf //add the turf underneath

	for(var/d in cardinal)//for every direction in cardinals
		distance = 0
		floor = src.loc
		while(true)
			floor = get_step(floor, d)
			if(!istype(floor)) break //if its not a flock tile just stop,
			if(floor.broken) break
			if(distance >= maxrange) break
			distance++
			connectedto |= floor

	for(var/turf/simulated/floor/feather/flocktile as anything in connectedto)
		flocktile.connected = 1
		flocktile.on() //make it glo


