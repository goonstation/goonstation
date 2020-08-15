//
//Collector structure
//
/obj/flock_structure/collector
	name = "Some weird lookin' pulsing thing"
	desc = "Seems to be pulsing."
	flock_id = "Collector"
	var/powergen = 0 //howmuch it make
	var/drawfromgrid = 0 //does it draw from the local apc if its strong enough.
	var/active = 0 //is it active?
	var/maxrange = 5 //max range for the thing.
	var/connected = 0 //amount of tiles "connected" to.
	var/list/connectedto = list() //the tiles its connected to
	poweruse = 0
	usesgroups = 1
//	icon = uhhh
//	icon_state = uhhh^2

/obj/flock_structure/collector/New(var/atom/location, var/datum/flock/F=null)
	..(location, F)

/obj/flock_structure/collector/building_specific_info()
	var/custominfo = "<span class='bold'>Connections:</span> Currently Connected to [connected] tile[connected == 1 ? "" : "s"]."
	custominfo += "<br><span class='bold'>Power generation:</span> Currently generating [powergen]."
	return custominfo

/obj/flock_structure/collector/process()
	..()
	calcconnected()
	src.poweruse = ((connected * 5) / -1) //power = tiles connected * 5 / 1 (5 power per tile)


/obj/flock_structure/collector/proc/calcconnected()
	for(var/turf/simulated/floor/feather/f in connectedto)
		f.off()
		f.connected = 0
	connectedto.len = 0
	var/myturf = get_turf(src)
	var/distance = 0 //how far has it gone already?
	var/turf/simulated/floor/feather/floor
	if(istype(myturf, /turf/simulated/floor/feather))
		connectedto += myturf //add the turf underneath

/*
	for(var/d in cardinal)//for every direction in cardinals
		while(true)
			var/turf/simulated/floor/feather/F = get_step(src.loc, d)
			if(!istype(F)) break //if its not a flock tile just stop,
			else//this is an else of the above if (the istype one) statement
				tilesfound |= F
*/
//TODO:replace the mess below with this thing above

	//north first
	var/turftocheck = get_step(myturf, NORTH)
	distance++
	while(true) //infiniteloop.jgp
		if(!istype(turftocheck, /turf/simulated/floor/feather)) break
		floor = turftocheck
		if(floor.broken) break//if they aint broken add em
		connectedto += turftocheck
		if(distance >= maxrange) break
		distance++
		turftocheck = get_step(turftocheck, NORTH)

	//east
	distance = 0
	turftocheck = get_step(myturf, EAST)
	distance++
	while(true)
		if(!istype(turftocheck, /turf/simulated/floor/feather)) break
		floor = turftocheck
		if(floor.broken) break//if they aint broken add em
		connectedto += turftocheck
		if(distance >= maxrange) break
		distance++
		turftocheck = get_step(turftocheck, EAST)

	//south
	distance = 0
	turftocheck = get_step(myturf, SOUTH)
	distance++
	while(true)
		if(!istype(turftocheck, /turf/simulated/floor/feather)) break
		floor = turftocheck
		if(floor.broken) break//if they aint broken add em
		connectedto += turftocheck
		if(distance >= maxrange) break
		distance++
		turftocheck = get_step(turftocheck, SOUTH)

	//west
	distance = 0
	turftocheck = get_step(myturf, WEST)
	distance++
	while(true)
		if(!istype(turftocheck, /turf/simulated/floor/feather)) break
		floor = turftocheck
		if(floor.broken) break//if they aint broken add em
		connectedto += turftocheck
		if(distance >= maxrange) break
		distance++
		turftocheck = get_step(turftocheck, WEST)

	for(var/turf/simulated/floor/feather/f in connectedto)
		f.connected = 1
		f.on() //make it glo

	connected = connectedto.len



