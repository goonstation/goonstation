//essential part of the ship,provides power to other components
//enables travel to other Z-Spaces.
/obj/item/shipcomponent/engine
	name = "Warp-1 Engine"
	desc = "A standard engine."
	var/powergenerated = 200 //how much power for components the engine generates
	var/currentgen = 200 //handles engine power debuffs
	var/warprecharge = 300 //Interval it takes for warp to be ready again
	//delay between dropping wormhole and being able to enter it
	var/portaldelay = 3 SECONDS
	var/status = "Normal"
	// multiplicative speed mod this engine has on its pod's speed
	var/engine_speed = 1
	var/wormholeQueued = 0 //so users cant open a million inputs and bypass all cooldowns
	var/warp_autopilot = 0		//prevents us from mistakenly moving when trying to warp. Checked in pod movement_controller
	power_used = 0
	system = "Engine"
	icon_state = "engine-1"

	get_desc()
		return "Rated for [src.powergenerated] units of continuous power output."

	activate()
		..()
		if(ship.fueltank?.air_contents.toxins <= 0)
			boutput(usr, "[ship.ship_message("No plasma located inside of the fuel tank!")]")
			src.deactivate()
			return
		ship.powercapacity = src.powergenerated
		src.ship.speedmod *= src.engine_speed
		return
	////Warp requires recharge time
	ready()
		SPAWN(warprecharge)
			ready = 1
			wormholeQueued = 0

	deactivate()
		..()
		ship.powercapacity = 0
		src.ship.speedmod /= src.engine_speed
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
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
			// ready = 0
			return
	else if (istype(ship.movement_controller, /datum/movement_controller/tank))
		var/datum/movement_controller/tank/MCT = ship.movement_controller
		if (MCT.input_x != 0 || MCT.input_y != 0)
			boutput(usr, "[ship.ship_message("Ship must have ZERO relative velocity (be stopped) to calculate warp destination!")]")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50)

	var/list/beacons = list()
	var/list/count = list() // associative list of number of times names in beacons are used (if possibly occuring more than once)
	//This is bad and dumb. I should turn the by_type[/obj/warp_beacon] list into a manager datum, but this is already taking too long. -kyle
	//I realize the possiblity of a bug where if you sit here ready to warp when it's about to change and then warp, but whatever
#if defined(MAP_OVERRIDE_POD_WARS)
	var/pilot_team = get_pod_wars_team_num(ship?.pilot)
	for(var/obj/warp_beacon/pod_wars/W in by_type[/obj/warp_beacon])
		if (W.current_owner == pilot_team)
			beacons[W.name] = W
#else
	for(var/obj/warp_beacon/W in by_type[/obj/warp_beacon])
		if(W.encrypted)
			if(QDELETED(ship.com_system) || !(W.encrypted in ship.com_system.access_type))
				continue
		count[W.name]++
		beacons["[W.name][count[W.name] == 1 ? null : " #[count[W.name]]"]"] = W
#endif
	for (var/obj/machinery/tripod/T in machine_registry[MACHINES_MISC])
		if (istype(T.bulb, /obj/item/tripod_bulb/beacon))
			count[T.name]++
			beacons["[T.name][count[T.name] == 1 ? null : " #[count[T.name]]"]"] = T
	wormholeQueued = 1
	var/obj/target = beacons[tgui_input_list(usr, "Please select a location to warp to.", "Warp Computer", sortList(beacons, /proc/cmp_text_asc))]
	if(!target || usr.loc != src.ship) // we need to make sure the user is still in the vehicle or selected a target
		wormholeQueued = 0
		return

#if defined(MAP_OVERRIDE_POD_WARS)
	var/obj/warp_beacon/pod_wars/W = target
	if (istype(W) && W.current_owner != pilot_team)
		boutput(usr, "Your access codes to this beacon are no longer working!")
		return
#endif
	var/turf/T = ship.loc
	if (!T.allows_vehicles)
		boutput(usr, "[ship.ship_message("Cannot create wormhole on this flooring!")]")
		return

	//starting warp
	playsound(src, 'sound/machines/boost.ogg', 75)

	//the chargeup/runway bit
	var/warp_dir = ship.dir
	warp_autopilot = 1
	var/const/max_steps = 2
	boutput(usr, "[ship.ship_message("Charging engines for wormhole creation! Overriding manual control!")]")

	var/obj/warp_portal/P = new /obj/warp_portal( ship.loc )
	P.transform = matrix(0, MATRIX_SCALE)
	for(var/i=0, i<max_steps, i++)
		step(P, warp_dir)

	var/dist = GET_DIST(src, P)
	portal_px_offset(P, warp_dir, dist)
	animate(P, transform = matrix(1, MATRIX_SCALE), pixel_x = 0, pixel_y = 0, time = 30, easing = ELASTIC_EASING )

	sleep(portaldelay)
	P.target = target
	if (istype(target, /obj/warp_beacon))
		var/obj/warp_beacon/WB = target
		if (WB.encrypted) // special beacon, ignore restricted Z checks and similar
			P.bypass_tele_block = TRUE
	ready = 0
	warp_autopilot = 0
	logTheThing(LOG_STATION, usr, "creates a wormhole (pod portal) (<b>Destination:</b> [target]) at [log_loc(usr)].")
	ready()


/obj/item/shipcomponent/engine/proc/portal_px_offset(var/atom/A, var/direction, var/dist)
	switch(direction)
		if(NORTH)
			A.pixel_y = -dist*32
		if(SOUTH)
			A.pixel_y = dist*32
		if(EAST)
			A.pixel_x = -dist*32
		if(WEST)
			A.pixel_x = dist*32
		if(NORTHEAST)
			A.pixel_y = -dist*32
			A.pixel_x = -dist*32
		if(NORTHWEST)
			A.pixel_y = -dist*32
			A.pixel_x = dist*32
		if(SOUTHEAST)
			A.pixel_y = dist*32
			A.pixel_x = -dist*32
		if(SOUTHWEST)
			A.pixel_y = dist*32
			A.pixel_x = dist*32

/obj/item/shipcomponent/engine/scout
	name = "Scout Engine"
	desc = "An engine optimized for speed and warp travel over power. Warning: Power is insufficient to operate most non-factory installed pod components."
	powergenerated = 50
	currentgen = 50
	warprecharge = 5 SECONDS
	engine_speed = 1.4
	icon_state = "engine-0"

/obj/item/shipcomponent/engine/helios
	name = "Helios Mark-II Engine"
	desc = "A really fast engine."
	powergenerated = 300 //how much power for components the engine generates
	currentgen = 300 //handles engine power debuffs
	warprecharge = 150 //Interval it takes for warp to be ready again
	engine_speed = 1.25
	icon_state = "engine-2"

/obj/item/shipcomponent/engine/hermes
	name = "Hermes 3.0 Engine"
	desc = "An incredibly powerful but slow engine."
	powergenerated = 500
	currentgen = 500
	warprecharge = 300
	engine_speed = 0.5
	icon_state = "engine-3"

/obj/item/shipcomponent/engine/zero
	name = "Warp-0 Engine"
	desc = "An old prototype engine."
	powergenerated = 190
	currentgen = 190
	warprecharge = -1 //This disables the ability to create wormholes completely.
	engine_speed = 1.1
	icon_state = "engine-4"

/obj/item/shipcomponent/engine/escape
	name = "Rickety Old Engine"
	desc = "This engine can probably make a warp jump. Once."
	warprecharge = 20 MINUTES
	portaldelay = 0 SECONDS
