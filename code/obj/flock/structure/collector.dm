/////////////////////////////////////////////////////////////////////////////////
// COLLECTOR
/////////////////////////////////////////////////////////////////////////////////
/obj/flock_structure/collector
	name = "weird lookin' pulsing thing"
	desc = "Seems to be pulsing."
	flock_desc = "Provides compute power and charges a nearby APC based on the number of Flock floor tiles it is connected to."
	flock_id = "Collector"
	health = 60
	resourcecost = 200
	show_in_tutorial = TRUE
	/// does it draw from the local apc if its strong enough.
	var/drawfromgrid = FALSE
	/// is it active?
	var/active = FALSE
	/// max range for the thing.
	var/maxrange = 5
	/// the tiles its connected to
	var/list/turf/simulated/floor/feather/connectedto = list()
	/// the apc it charges
	var/obj/machinery/power/apc/area_apc = null
	/// the area the collector is in
	var/area/src_area = null
	/// percent charge of connected apc it will charge per cycle
	var/charge_per_cycle = 0
	/// charge cycle time
	var/charge_cycle = 20 SECONDS

	passthrough = TRUE

	icon_state = "collector"

/obj/flock_structure/collector/New(var/atom/location, var/datum/flock/F=null)
	..(location, F)
	src.info_tag.set_info_tag("Compute provided: [src.compute]")
	src.area_apc = get_local_apc(src)
	src.src_area = get_area(src)
	ON_COOLDOWN(src, "apc_charging", src.charge_cycle)

/obj/flock_structure/collector/building_specific_info()
	return {"<span class='bold'>Connections:</span> Currently Connected to [length(connectedto)] tile[length(connectedto) == 1 ? "" : "s"].
	<br><span class='bold'>Compute generation:</span> Currently generating [src.compute_provided()].
	<br><span class='bold'>APC connected:</span> [!src.area_apc?.cell || src.area_apc.cell.charge >= src.area_apc.cell.maxcharge ? "Not charging APC" : "Charging local APC at [src.charge_per_cycle]% every [src.charge_cycle / 10] seconds"]."}

/obj/flock_structure/collector/process(mult)
	..()
	calcconnected()
	if(length(connectedto))
		icon_state = "collectoron"
	else
		icon_state = "collector"
	var/comp = (length(connectedto) * 5) //(5 power per tile)
	src.charge_per_cycle = length(connectedto) * 0.25
	if (src.compute != comp)
		src.update_flock_compute("remove", FALSE)
		src.compute = comp
		src.update_flock_compute("apply")
		src.info_tag.set_info_tag("Compute provided: [src.compute]")
	if (src.charge_per_cycle)
		if (QDELETED(src.area_apc) || src.area_apc.area != src.src_area)
			src.area_apc = get_local_apc(src)
			if (QDELETED(src.area_apc))
				return
		if (!src.area_apc.cell || src.area_apc.cell.charge >= src.area_apc.cell.maxcharge || src.area_apc.status & BROKEN)
			return
		if (!ON_COOLDOWN(src, "apc_charging", src.charge_cycle))
			src.area_apc.cell.give(src.charge_per_cycle / 100 * src.area_apc.cell.maxcharge * mult)
			src.area_apc.AddComponent(/datum/component/flock_ping/apc_power)

/obj/flock_structure/collector/Move(NewLoc, direct)
	. = ..()
	src.src_area = get_area(src)

/obj/flock_structure/collector/disposing()
	for(var/turf/simulated/floor/feather/flocktile as anything in connectedto)
		flocktile.off()
	connectedto.len = 0
	src.area_apc = null
	src.src_area = null
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


