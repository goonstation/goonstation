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
	var/warp_autopilot = 0		//prevents us from mistakenly moving when trying to warp. Checked in pod movement_controller
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
		src.add_dialog(user)

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
	if (wormholeQueued || warprecharge == -1)
		return
	//check for sensors, maybe communications too?
	var/obj/item/shipcomponent/sensor/S = ship.sensors
	if (istype(S))
		if (!S.active)
			boutput(usr, "[ship.ship_message("Sensors inactive! Unable to calculate warp trajectory!")]")
			return
	else
		boutput(usr, "[ship.ship_message("No sensors detected! Unable to calculate warp trajectory!")]")
		return

	//brake the pod, we must stop to calculate warp trajectory. 
	if (istype(ship.movement_controller, /datum/movement_controller/pod))
		var/datum/movement_controller/pod/MCP = ship.movement_controller
		if (MCP.velocity_x != 0 || MCP.velocity_y != 0)
			boutput(usr, "[ship.ship_message("Ship must have ZERO relative velocity to calculate warp destination!")]")
			playsound(src, "sound/machines/buzz-sigh.ogg", 50)
			// ready = 0
			return
	else if (istype(ship.movement_controller, /datum/movement_controller/tank))
		var/datum/movement_controller/tank/MCT = ship.movement_controller
		if (MCT.input_x != 0 || MCT.input_y != 0)
			boutput(usr, "[ship.ship_message("Ship must have ZERO relative velocity (be stopped) to calculate warp destination!")]")
			playsound(src, "sound/machines/buzz-sigh.ogg", 50)


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

	//starting warp
	playsound(src, "sound/machines/boost.ogg", 75)

	//the chargeup/runway bit
	var/warp_dir = ship.dir
	var/turf/prev_turf = null
	var/turf/NT = get_turf(src)
	var/const/max_steps = 7
	warp_autopilot = 1
	for(var/i=0, i<max_steps, i++)
		NT = get_step(NT, warp_dir)
		ship.Move(NT)

		if (prev_turf == ship.loc)
			boutput(usr, "[ship.ship_message("Insufficient runway distance to create wormhole!")]")
			playsound(src, "sound/machines/buzz-sigh.ogg", 50)
			wormholeQueued = 0
			warp_autopilot = 0
			return
		prev_turf = NT
		//on the penultimate step, make the portal before we wait so they see it breifly
		if (i == max_steps-2)
			var/obj/warp_portal/P = new /obj/warp_portal( NT )
			P.target = target
			step(P, warp_dir)
		sleep(0.5 SECONDS)

	ready = 0
	warp_autopilot = 0
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
	warprecharge = 300
	speedmod = 3
	icon_state = "engine-3"

/obj/item/shipcomponent/engine/zero
	name = "Warp-0 Engine"
	desc = "An old prototype engine"
	powergenerated = 190
	currentgen = 190
	warprecharge = -1 //This disables the ability to create wormholes completely.
	speedmod = 2
	icon_state = "engine-4"