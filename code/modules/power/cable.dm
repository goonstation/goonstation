
/atom/proc/electrocute(mob/user, prb, netnum, var/ignore_gloves)

	if(!prob(prb))
		return 0

	if(!netnum)		// unconnected cable is unpowered
		return 0

	var/datum/powernet/PN
	if(powernets && powernets.len >= netnum)
		PN = powernets[netnum]

	elecflash(src)

	return user.shock(src, PN ? PN.avail : 0, user.hand == LEFT_HAND ? "l_arm": "r_arm", 1, ignore_gloves ? 1 : 0)

/// attach a wire to a power machine - leads from the turf you are standing on
/obj/machinery/power/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/cable_coil))
		var/obj/item/cable_coil/coil = W

		var/turf/T = user.loc

		if(T.intact || !istype(T, /turf/simulated/floor))
			return

		if(BOUNDS_DIST(src, user) > 0)
			return

		if(!directwired)		// only for attaching to directwired machines
			return

		var/dirn = get_dir(user, src)

		for(var/obj/cable/LC in T)
			if(LC.d1 == dirn || LC.d2 == dirn)
				boutput(user, "There's already a cable at that position.")
				return

		var/obj/cable/NC = new(T, coil)
		NC.d1 = 0
		NC.d2 = dirn
		NC.iconmod = coil.iconmod
		NC.add_fingerprint()
		NC.UpdateIcon()
		NC.update_network()
		coil.use(1)
	else
		..()

/// the power cable object
/obj/cable
	level = 1
	anchored = TRUE
	jpsUnstable = FALSE
	var/tmp/netnum = 0
	name = "power cable"
	desc = "A flexible power cable."
	icon = 'icons/obj/power_cond.dmi'
	icon_state = "0-1"
	var/d1 = 0
	var/d2 = 1
	var/iconmod = null
	//var/image/cableimg = null
	//^ is unnecessary, i think
	layer = CABLE_LAYER
	plane = PLANE_NOSHADOW_BELOW
	color = "#DD0000"
	text = ""

	var/insulator_default = "synthrubber"
	var/condcutor_default = "copper"

	var/datum/material/insulator = null
	var/datum/material/conductor = null

	conduit
		name = "power conduit"
		desc = "A rigid assembly of superconducting power lines."
		icon_state = "conduit"

/obj/cable/reinforced
	name = "reinforced power cable"
	desc = "A flexible yet extremely thick power cable. How paradoxical."
	icon_state = "0-1-thick"
	iconmod = "-thick"
	color = "#075C90"

	condcutor_default = "pharosium"
	insulator_default = "synthblubber"

	//same as normal cables but you have to click them multiple cuts heheheh
	var/static/cuts_required = 3
	var/cuts = 0

	get_desc(dist, mob/user)
		if(dist < 4 && cuts)
			.= "<br>" + "The cable looks partially cut."


	cut(mob/user,turf/T)
		cuts++
		shock(user, 50)
		var/num = "first"
		if (cuts == 2)
			num = "second"
		if (cuts == 3)
			num = "third"
		if (cuts == 4)
			num = "fourth"
		if (cuts == 5)
			num = "fifth"
		src.visible_message("<span class='alert'>[user] cuts through the [num] section of [src].</span>")

		if (cuts >= cuts_required)
			..()
		else
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)

/obj/cable/New(var/newloc, var/obj/item/cable_coil/source)
	..()
	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	d1 = text2num( icon_state )

	d2 = text2num( copytext( icon_state, findtext(icon_state, "-")+1 ) )

	if (source)
		src.iconmod = source.iconmod

	var/turf/T = src.loc

	if (isnull(T)) // we are getting immediately deleted? lol
		return

	// hide if turf is not intact
	// but show if in space
	if(istype(T, /turf/space) && !istype(T,/turf/space/fluid))
		hide(0)
	else if(level==1)
		hide(T.intact)

	//cableimg = image(src.icon, src.loc, src.icon_state)
	//cableimg.layer = OBJ_LAYER

	if (istype(source))
		applyCableMaterials(src, source.insulator, source.conductor)
	else
		applyCableMaterials(src, getMaterial(insulator_default), getMaterial(condcutor_default), copy_material = FALSE)

	START_TRACKING

/obj/cable/disposing()		// called when a cable is deleted
	if(!defer_powernet_rebuild)	// set if network will be rebuilt manually
		if(netnum && powernets && length(powernets) >= netnum)		// make sure cable & powernet data is valid
			var/datum/powernet/PN = powernets[netnum]
			PN.cut_cable(src)									// updated the powernets
	else
		defer_powernet_rebuild = 2

		if(netnum && powernets && length(powernets) >= netnum) //NEED FOR CLEAN GC IN EXPLOSIONS
			powernets[netnum].cables -= src

	insulator.owner = null
	conductor.owner = null

	STOP_TRACKING

	..()													// then go ahead and delete the cable

/obj/cable/hide(var/i)
	if(level == 1)// && istype(loc, /turf/simulated))
		invisibility = i ? INVIS_ALWAYS : INVIS_NONE
	UpdateIcon()

/obj/cable/update_icon()
	icon_state = "[d1]-[d2][iconmod]"
	alpha = invisibility ? 128 : 255
	//if (cableimg)
	//	cableimg.icon_state = icon_state
	//	cableimg.alpha = invisibility ? 128 : 255

/// returns the powernet this cable belongs to
/obj/cable/proc/get_powernet()
	var/datum/powernet/PN			// find the powernet
	if(netnum && powernets && powernets.len >= netnum)
		PN = powernets[netnum]
	if (isnull(PN) && netnum)
		CRASH("Attempted to get powernet number [netnum] but it was null.")
	return PN

/obj/cable/proc/cut(mob/user,turf/T)
	if(src.d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
		var/atom/A = new/obj/item/cable_coil(T, 2)
		applyCableMaterials(A, src.insulator, src.conductor)
		if (src.iconmod)
			var/obj/item/cable_coil/C = A
			C.iconmod = src.iconmod
			C.UpdateIcon()
	else
		var/atom/A = new/obj/item/cable_coil(T, 1)
		applyCableMaterials(A, src.insulator, src.conductor)
		if (src.iconmod)
			var/obj/item/cable_coil/C = A
			C.iconmod = src.iconmod
			C.UpdateIcon()

	src.visible_message("<span class='alert'>[user] cuts the cable.</span>")
	src.log_wirelaying(user, 1)

	shock(user, 50)

	defer_powernet_rebuild = 0		// to fix no-action bug
	qdel(src)
	return


/obj/cable/attackby(obj/item/W, mob/user)

	var/turf/T = src.loc
	if (T.intact)
		return

	if (issnippingtool(W))
		src.cut(user,T)
		return	// not needed, but for clarity

	else if (istype(W, /obj/item/cable_coil))
		var/obj/item/cable_coil/coil = W
		coil.cable_join(src, get_turf(user), user, TRUE)
		//note do shock in cable_join

	else if (istype(W, /obj/item/device/t_scanner) || ispulsingtool(W) || (istype(W, /obj/item/device/pda2) && istype(W:module, /obj/item/device/pda_module/tray)))

		var/datum/powernet/PN = get_powernet()		// find the powernet
		var/powernet_id = ""

		if(PN && ispulsingtool(W))
			// 3 Octets: Netnum, 4 Octets: Nodes+Data Nodes*2, 4 Octets: Cable Count
			powernet_id = " ID#[num2text(PN.number,3,8)]:[num2text(length(PN.nodes)+(length(PN.data_nodes)<<2),4,8)]:[num2text(length(PN.cables),4,8)]"

		if(PN?.avail > 0)		// is it powered?

			boutput(user, "<span class='alert'>[PN.avail]W in power network. [powernet_id]</span>")

		else
			boutput(user, "<span class='alert'>The cable is not powered. [powernet_id]</span>")

		if(prob(40))
			shock(user, 10)

	else
		shock(user, 10)

	src.add_fingerprint(user)

// shock the user with probability prb

/obj/cable/proc/shock(mob/user, prb)
	if(!netnum)		// unconnected cable is unpowered
		return 0

	return src.electrocute(user, prb, netnum)

/obj/cable/ex_act(severity)
	switch (severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(15))
				var/atom/A = new/obj/item/cable_coil(src.loc, src.d1 ? 2 : 1)
				applyCableMaterials(A, src.insulator, src.conductor)
			qdel(src)

/obj/cable/reinforced/ex_act(severity)
	return //nah

// called when a new cable is created
// can be 1 of 3 outcomes:
// 1. Isolated cable (or only connects to isolated machine) -> create new powernet
// 2. Joins to end or bridges loop of a single network (may also connect isolated machine) -> add to old network
// 3. Bridges gap between 2 networks -> merge the networks (must rebuild lists also) (currently just calls makepowernets. welp)
/obj/cable/proc/update_network()
	if(makingpowernets) // this might cause local issues but prevents a big global race condition that breaks everything
		return
	var/turf/T = get_turf(src)
	var/obj/cable/cable_d1 = null //locate() in (d1 ? get_step(src,d1) : orange(0, src) )
	var/obj/cable/cable_d2 = null //locate() in (d2 ? get_step(src,d2) : orange(0, src) )
	var/request_rebuild = 0

	for (var/obj/cable/new_cable_d1 in src.get_connections_one_dir(is_it_d2 = 0))
		cable_d1 = new_cable_d1
		break

	for (var/obj/cable/new_cable_d2 in src.get_connections_one_dir(is_it_d2 = 1))
		cable_d2 = new_cable_d2
		break

	// due to the first two lines of this proc it can happen that some cables are left at netnum 0, oh no
	// this is bad and should be fixed, probably by having a queue of stuff to process once current makepowernets finishes
	// but I'm too lazy to do that, so here's a bandaid
	if(cable_d1 && !cable_d1.netnum)
		logTheThing(LOG_DEBUG, src, "Cable \ref[src] ([src.x], [src.y], [src.z]) connected to \ref[cable_d1] which had netnum 0, rebuilding powernets.")
		DEBUG_MESSAGE("Cable \ref[src] ([src.x], [src.y], [src.z]) connected to \ref[cable_d1] which had netnum 0, rebuilding powernets.")
		return makepowernets()
	if(cable_d2 && !cable_d2.netnum)
		logTheThing(LOG_DEBUG, src, "Cable \ref[src] ([src.x], [src.y], [src.z]) connected to \ref[cable_d2] which had netnum 0, rebuilding powernets.")
		DEBUG_MESSAGE("Cable \ref[src] ([src.x], [src.y], [src.z]) connected to \ref[cable_d2] which had netnum 0, rebuilding powernets.")
		return makepowernets()

	if (cable_d1 && cable_d2)
		if (cable_d1.netnum == cable_d2.netnum && powernets[cable_d1.netnum])
			var/datum/powernet/PN = powernets[cable_d1.netnum]
			PN.cables += src
			src.netnum = cable_d1.netnum
		else
			var/datum/powernet/P1 = cable_d1.get_powernet()
			var/datum/powernet/P2 = cable_d2.get_powernet()
			src.netnum = cable_d1.netnum
			P1.cables += src
			if(P1.cables.len <= P2.cables.len)
				P1.join_to(P2)
			else
				P2.join_to(P1)

	else if (!cable_d1 && !cable_d2)
		var/datum/powernet/PN = new()
		powernets += PN
		PN.cables += src
		PN.number = length(powernets)
		src.netnum = length(powernets)

	else if (cable_d1)
		var/datum/powernet/PN = powernets[cable_d1.netnum]
		PN.cables += src
		src.netnum = cable_d1.netnum

	else
		var/datum/powernet/PN = powernets[cable_d2.netnum]
		PN.cables += src
		src.netnum = cable_d2.netnum

	if (isturf(T) && d1 == 0 && !request_rebuild)
		for (var/obj/machinery/power/M in T.contents)
			if(M.directwired)
				continue
			if(M.netnum == 0 || powernets[M.netnum].cables.len == 0)
				if(M.netnum)
					M.powernet.nodes -= M
					M.powernet.data_nodes -= M
				M.netnum = src.netnum
				M.powernet = powernets[M.netnum]
				M.powernet.nodes += M
				if(M.use_datanet)
					M.powernet.data_nodes += M
			else if(M.netnum != src.netnum) // this shouldn't actually ever happen probably
				request_rebuild = 1
				break
	if(d1 != 0 && !request_rebuild)
		var/turf/T1 = get_step(src, d1)
		for (var/obj/machinery/power/M in T1.contents)
			if(!M.directwired)
				continue
			if(M.netnum == 0 || powernets[M.netnum].cables.len == 0)
				if(M.netnum)
					M.powernet.nodes -= M
					M.powernet.data_nodes -= M
				M.netnum = src.netnum
				M.powernet = powernets[M.netnum]
				M.powernet.nodes += M
				if(M.use_datanet)
					M.powernet.data_nodes += M
			else if(M.netnum != src.netnum)
				request_rebuild = 1
				break
	if(!request_rebuild)
		var/turf/T2 = get_step(src, d2)
		for (var/obj/machinery/power/M in T2.contents)
			if(!M.directwired || M.netnum == -1) // APCs have -1 and don't connect directly
				continue
			if(M.netnum == 0 || powernets[M.netnum].cables.len == 0)
				if(M.netnum)
					M.powernet.nodes -= M
					M.powernet.data_nodes -= M
				M.netnum = src.netnum
				M.powernet = powernets[M.netnum]
				M.powernet.nodes += M
				if(M.use_datanet)
					M.powernet.data_nodes += M
			else if(M.netnum != src.netnum)
				request_rebuild = 1
				break

	if(request_rebuild)
		makepowernets()

	//powernets are really in need of a renovation.  makepowernets() is called way too much and is really intensive on the server ok.

// Some non-traitors love to hotwire the engine (Convair880).
/obj/cable/proc/log_wirelaying(var/mob/user, var/cut = 0)
	if (!src || !istype(src) || !user || !ismob(user))
		return

	var/powered = 0
	var/datum/powernet/PN = src.get_powernet()
	if (PN && istype(PN) && (PN.avail > 0))
		powered = 1


	if (cut) //avoid some slower string builds lol
		logTheThing(LOG_STATION, user, "cuts a cable[powered == 1 ? " (powered when cut)" : ""] at [log_loc(src)].")
	else
		logTheThing(LOG_STATION, user, "lays a cable[powered == 1 ? " (powered when connected)" : ""] at [log_loc(src)].")

	return

/// a cable spawner which can spawn multiple cables to connect to other cables around it.
/obj/cablespawner
	name = "power cable spawner"
	icon = 'icons/obj/power_cond.dmi'
	icon_state = "superstate"
	layer = CABLE_LAYER
	plane = PLANE_NOSHADOW_BELOW
	color = "#DD0000"
	// this would make it connect to the centre, for like terminals and whatnot
	// has to be var edited because lazy
	var/override_centre_connection = FALSE
	var/cable_type = /obj/cable
	// cable_surr uses the macros NORTHEAST_UNIQUE and such to save directions
	var/cable_surr = 0

/obj/cablespawner/New()
	..()
	if(current_state >= GAME_STATE_WORLD_INIT && !src.disposed)
		SPAWN(1 SECONDS)
			if(!src.disposed)
				initialize()

/obj/cablespawner/node
	name = "node cable spawner"
	override_centre_connection = TRUE
	icon_state = "superstate-node"

/// reinforced, thick cables. They should also connect to the regular kind.
/obj/cablespawner/reinforced
	name = "reinforced power cable spawner"
	icon = 'icons/obj/power_cond.dmi'
	icon_state = "superstate-thick"
	cable_type = /obj/cable/reinforced
	color = "#075C90"

/obj/cablespawner/reinforced/node
	name = "node reinforced cable spawner"
	override_centre_connection = TRUE
	icon_state = "superstate-thick-node"


/// makes the cable spawners actually spawn cables and delete themselves
/obj/cablespawner/initialize()
	. = ..()
	src.check()
	src.replace()

/// checks around itself for cables, adds up to 8 bits to cable_surr
/obj/cablespawner/proc/check(var/obj/cable/cable)
	for (var/obj/cablespawner/spawner in orange(1, src))
	// checks for cablespawners around itself
		var/disx = spawner.x - src.x
		var/disy = spawner.y - src.y
		if (disy == 1)
			if (disx == 1)
				cable_surr |= NORTHEAST_UNIQUE
			else if (disx == -1)
				cable_surr |= NORTHWEST_UNIQUE
			else
				cable_surr |= NORTH
		else if (disy == -1)
			if (disx == 1)
				cable_surr |= SOUTHEAST_UNIQUE
			else if (disx == -1)
				cable_surr |= SOUTHWEST_UNIQUE
			else
				cable_surr |= SOUTH
		else if (disy == 0)
			if (disx == 1)
				cable_surr |= EAST
			else if (disx == -1)
				cable_surr |= WEST
	/*
	Diagonals are ugly. So if the option to connect to a diagonal tile orthogonally presents itself
	we'll get rid of the corners and connect in NESOUTHWEST_UNIQUE directions first.
	This gets rid of diagonals in 2x2 and 3x3 grids, and stops small 'L's from becoming triangles.
	if a diagonal tile is next to a cardinal, we disregard it.
	This won't work on the manually connected cables.
	*/
	if (cable_surr & NORTHEAST_UNIQUE)
		if (cable_surr & NORTH || cable_surr & EAST)
			cable_surr &= ~NORTHEAST_UNIQUE
	if (cable_surr & NORTHWEST_UNIQUE)
		if (cable_surr & NORTH || cable_surr & WEST)
			cable_surr &= ~NORTHWEST_UNIQUE
	if (cable_surr & SOUTHEAST_UNIQUE)
		if (cable_surr & SOUTH || cable_surr & EAST)
			cable_surr &= ~SOUTHEAST_UNIQUE
	if (cable_surr & SOUTHWEST_UNIQUE)
		if (cable_surr & SOUTH || cable_surr & WEST)
			cable_surr &= ~SOUTHWEST_UNIQUE
	/* there is exactly one case where this code breaks
	* consider a grid of: X
	*                     X X
	* The bottom left spawns in, connects to its two neighbours, and the bottom right connects in 2
	* directions. This if statement fixes that, by making the bottom left alter the bottom right one.
	*/
	if (cable_surr & EAST)
		for (var/obj/cablespawner/spawner in orange(1, src))
			if (spawner.x - src.x == 1 && spawner.y - src.y == 0)
				spawner.cable_surr |= WEST

	for (var/obj/cable/normal_cable in orange(1, src))
	// checks normal, prexisting, manually placed cables (must be joined to no matter what)
	// turns out, since initialize() does cablespawners one by one
	// they turn into regular cables and must be considered like that by the system
	// making this bit MANDATORY
		var/disx = normal_cable.x - src.x
		var/disy = normal_cable.y - src.y
		if (disy == 1)
			if (disx == 1)
				if (normal_cable.d1 == SOUTHWEST || normal_cable.d2 == SOUTHWEST)
					cable_surr |= NORTHEAST_UNIQUE
			else if (disx == -1)
				if (normal_cable.d1 == SOUTHEAST || normal_cable.d2 == SOUTHEAST)
					cable_surr |= NORTHWEST_UNIQUE
			else if (normal_cable.d1 == SOUTH || normal_cable.d2 == SOUTH)
				cable_surr |= NORTH
		else if (disy == -1)
			if (disx == 1)
				if (normal_cable.d1 == NORTHWEST || normal_cable.d2 == NORTHWEST)
					cable_surr |= SOUTHEAST_UNIQUE
			else if (disx == -1)
				if (normal_cable.d1 == NORTHEAST || normal_cable.d2 == NORTHEAST)
					cable_surr |= SOUTHWEST_UNIQUE
			else if (normal_cable.d1 == NORTH || normal_cable.d2 == NORTH)
				cable_surr |= SOUTH
		else if (disy == 0)
			if (disx == 1)
				if (normal_cable.d1 == WEST || normal_cable.d2 == WEST)
					cable_surr |= EAST
			else if (disx == -1)
				if (normal_cable.d1 == EAST || normal_cable.d2 == EAST)
					cable_surr |= WEST
		// the 'real' wires override and always connect to prevent loose ends
		// cable_surr is any direction that needs to be connected to at all
		// this bit does not get optimised

/// causes cablespawner to spawn cables (amazing)
/obj/cablespawner/proc/replace()
	var/list/directions = list()
	if (cable_surr & NORTH)
		directions += NORTH
	if (cable_surr & SOUTH)
		directions += SOUTH
	if (cable_surr & EAST)
		directions += EAST
	if (cable_surr & NORTHEAST_UNIQUE)
		directions += NORTHEAST
	if (cable_surr & SOUTHEAST_UNIQUE)
		directions += SOUTHEAST
	if (cable_surr & WEST)
		directions += WEST
	if (cable_surr & NORTHWEST_UNIQUE)
		directions += NORTHWEST
	if (cable_surr & SOUTHWEST_UNIQUE)
		directions += SOUTHWEST

	if (length(directions) == 0)
		cable_laying(0,NORTH)
	// multiple cables, spiral out from the centre
	else if (src.override_centre_connection)
		for (var/i in 1 to length(directions))
			cable_laying(0, directions[i])
	else if (length(directions) >= 3)
		for (var/i in 1 to length(directions))
			cable_laying(0, directions[i])
	else if (length(directions) == 1)
	// end of a cable
		cable_laying(0, directions[1])
	else if (length(directions) == 2)
	// a normal, single cable
		cable_laying(directions[1], directions[2])
	qdel(src)

/// places a cable with d1 and d2
/obj/cablespawner/proc/cable_laying(var/dir1, var/dir2)
	var/obj/cable/current = new src.cable_type(src.loc)
	current.d1 = dir1
	current.d2 = dir2
	current.UpdateIcon()
