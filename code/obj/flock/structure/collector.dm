/////////////////////////////////////////////////////////////////////////////////
// COLLECTOR
/////////////////////////////////////////////////////////////////////////////////
/obj/flock_structure/collector
	name = "weird lookin' pulsing thing"
	desc = "Seems to be pulsing."
	flock_desc = "Provides compute power based on the number of Flock floor tiles it is connected to."
	flock_id = "Collector"
	health = 60
	resourcecost = 200
	/// does it draw from the local apc if its strong enough.
	var/drawfromgrid = FALSE
	/// is it active?
	var/active = FALSE
	/// max range for the thing.
	var/maxrange = 5
	/// the tiles its connected to
	var/list/turf/simulated/floor/feather/connectedto = list()

	passthrough = TRUE

	icon_state = "collector"

/obj/flock_structure/collector/New(var/atom/location, var/datum/flock/F=null)
	..(location, F)
	src.info_tag.set_info_tag("Compute provided: [src.compute]")

/obj/flock_structure/collector/building_specific_info()
	return {"<span class='bold'>Connections:</span> Currently Connected to [length(connectedto)] tile[length(connectedto) == 1 ? "" : "s"].
	<br><span class='bold'>Compute generation:</span> Currently generating [src.compute_provided()]."}

/obj/flock_structure/collector/process()
	..()
	calcconnected()
	if(length(connectedto))
		icon_state = "collectoron"
	else
		icon_state = "collector"
	var/comp = (length(connectedto) * 5) //(5 power per tile)
	if (src.compute != comp)
		src.update_flock_compute("remove", FALSE)
		src.compute = comp
		src.update_flock_compute("apply")
		src.info_tag.set_info_tag("Compute provided: [src.compute]")

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
	if(!istype(floor)) return

	if(floor.broken) return
	connectedto += myturf

	for(var/d in cardinal)
		distance = 0
		floor = src.loc
		while(true)
			floor = get_step(floor, d)
			if(!istype(floor)) break
			if(floor.broken) break
			if(distance >= maxrange) break
			distance++
			connectedto |= floor

	for(var/turf/simulated/floor/feather/flocktile as anything in connectedto)
		flocktile.connected = TRUE
		flocktile.on()


