//
//Collector structure
//
/obj/flock_structure/collector
	name = "Some weird lookin' pulsing thing"
	desc = "Seems to be pulsing."
	flock_id = "Collector"
	var/drawfromgrid = 0 //does it draw from the local apc if its strong enough.
	var/active = 0 //is it active?
	var/maxrange = 5 //max range for the thing.
	var/connected = 0 //amount of tiles "connected" to.
	var/list/connectedto = list() //the tiles its connected to
	poweruse = 0
	usesgroups = 1
	icon_state = "collector"

/obj/flock_structure/collector/New(var/atom/location, var/datum/flock/F=null)
	..(location, F)

/obj/flock_structure/collector/building_specific_info()
	return {"<span class='bold'>Connections:</span> Currently Connected to [connected] tile[connected == 1 ? "" : "s"].
	<br><span class='bold'>Power generation:</span> Currently generating [abs(poweruse)]."}

/obj/flock_structure/collector/process()
	..()
	calcconnected()
	if(connected > 0)
		icon_state = "collectoron"
	else
		icon_state = "collector"
	src.poweruse = ((connected * 5) / -1) //power = tiles connected * 5 / 1 (5 power per tile)


/obj/flock_structure/collector/proc/calcconnected()
	for(var/turf/simulated/floor/feather/f in connectedto)
		f.off()
		f.connected = 0
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

	for(var/turf/simulated/floor/feather/f in connectedto)
		f.connected = 1
		f.on() //make it glo

	connected = length(connectedto)


