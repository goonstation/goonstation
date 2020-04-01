//essential part of the ship,provides power to other components
//enables travel to other Z-Spaces.
/obj/item/shipcomponent/engine
	name = "Warp-1 Engine"
	desc = "A standard engine"
	var/powergenerated = 200 //how much power for components the engine generates
	var/currentgen = 200 //handles engine power debuffs
	var/warprecharge = 300 //Interval it takes for warp to be ready again
	var/status = "Normal"
	var/speedmod = 2 // how fast should the vehicle be, lower is faster
	var/wormholeQueued = 0 //so users cant open a million inputs and bypass all cooldowns
	power_used = 0
	system = "Engine"
	icon_state = "engine-1"

	activate()
		..()
		ship.powercapacity = src.powergenerated
		return
	////Warp requires recharge time
	ready()
		SPAWN_DBG(warprecharge)
			ready = 1
			wormholeQueued = 0

	deactivate()
		..()
		ship.powercapacity = 0
		for(var/obj/item/shipcomponent/S in ship.components)
			if(S.active)
				S.deactivate()
		return

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		user.machine = src

		var/dat = "<TT><B>[src] Console</B><BR><HR><BR>"
		if(src.active)
			dat+=  {"<BR><B>Current Output:</B> [currentgen]"}
			dat+=  {"<BR><B>Standard Ouput:</B> [powergenerated]"}
			dat+=  {"<BR><B>Engine Status:</B> [status]"}
			dat+=  {"<BR><B>Current Load:</B> [ship.powercurrent]"}
			if(ready)
				dat+= {"<BR><B>Warp Status:</B> Ready"}
			else
				dat+= {"<BR><B>Warp Status:</B> Recharging"}
		else
			dat += {"<B><span style=\"color:red\">SYSTEM OFFLINE</span></B>"}
		user.Browse(dat, "window=ship_engine")
		onclose(user, "ship_engine")
		return

/obj/item/shipcomponent/engine/proc/Wormhole()
	if (wormholeQueued)
		return
	var/list/beacons = list()
	for(var/obj/warp_beacon/W in warp_beacons)
		beacons += W
	for (var/obj/machinery/tripod/T in machine_registry[MACHINES_MISC])
		if (istype(T.bulb, /obj/item/tripod_bulb/beacon))
			beacons += T
	wormholeQueued = 1
	var/obj/target = input(usr, "Please select a location to warp to.", "Warp Computer") as null|obj in beacons
	if(!target)
		wormholeQueued = 0
		return
	var/turf/T = ship.loc
	if (!T.allows_vehicles)
		boutput(usr, "[ship.ship_message("Cannot create wormhole on this flooring!")]")
		return
	var/obj/warp_portal/P = new /obj/warp_portal( ship.loc )
	P.target = target
	step(P, ship.dir)
	ready = 0
	logTheThing("station", usr, null, "creates a wormhole (pod portal) (<b>Destination:</b> [target]) at [log_loc(usr)].")
	ready()
/obj/item/shipcomponent/engine/helios
	name = "Helios Mark-II Engine"
	desc = "A really fast engine"
	powergenerated = 300 //how much power for components the engine generates
	currentgen = 300 //handles engine power debuffs
	warprecharge = 150 //Interval it takes for warp to be ready again
	speedmod = 1
	icon_state = "engine-2"

/obj/item/shipcomponent/engine/hermes
	name = "Hermes 3.0 Engine"
	desc = "An incredibly powerful but slow engine"
	powergenerated = 500
	currentgen = 500
	warprecharge =300
	speedmod = 3
	icon_state = "engine-3"
