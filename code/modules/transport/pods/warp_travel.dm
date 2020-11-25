///Warp Beacons and Wormholes
///Used by spaceships to travel to other Z-planes

var/global/list/warp_beacons = list() //wow you should've made one for warp beacons when you made one for normal tracking beacons huh

/obj/warp_beacon
	name = "warp beacon"
	desc = "Part of an elaborate small-ship teleportation network recently deployed by Nanotrasen.  Probably won't cause you to die."
	icon = 'icons/obj/ship.dmi'
	icon_state = "beacon"
	anchored = 1
	density = 1

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/machinery/door_control (door_control.dm)
	// /obj/machinery/r_door_control (door_control.dm)
	// /obj/machinery/door/poddoor/pyro (poddoor.dm)
	// /obj/machinery/door/poddoor/blast/pyro (poddoor.dm)
	// We don't need a complete copy of all hangars, though.
	// A limited-but-logical selection of beacon will suffice.
	catering
		name = "catering hangar beacon"
	arrivals
		name = "arrivals hangar beacon"
	escape
		name = "escape hangar beacon"
	mainpod1
		name = "main hangar beacon (#1)"
	mainpod2
		name = "main hangar beacon (#2)"
	engineering
		name = "engineering hangar beacon"
	security
		name = "security hangar beacon"
	medsci
		name = "medsci hangar beacon"
	research
		name = "research hangar beacon"
	medbay
		name = "medbay hangar beacon"
	qm
		name = "QM hangar beacon"
	mining
		name = "mining hangar beacon"
	miningoutpost
		name = "mining outpost beacon"
	miningasteroidbelt
#ifdef UNDERWATER_MAP
		name = "underwater mining beacon"
#else
		name = "asteroid belt mining beacon"
#endif
	diner
		name = "space diner beacon"
	faint //Manta beacon.
		name = "faint signal"
	front //Manta beacon.
		name = "Fore beacon"
	back //Manta beacon.
		name = "Aft beacon"
	starboard //Manta beacon.
		name = "Starboard beacon"
	port //Manta beacon.
		name = "Port beacon"
	trench_mining
		name = "Mining outpost beacon"
	sea_turtle
		name = "Sea Turtle beacon"

/obj/warp_beacon/New()
	..()
	SPAWN_DBG(0)
		if (!islist(warp_beacons))
			warp_beacons = list()
		warp_beacons.Add(src)

/obj/warp_beacon/disposing()
	..()
	if (islist(warp_beacons))
		warp_beacons.Remove(src)

/obj/warp_beacon/disposing()
	if (islist(warp_beacons))
		warp_beacons.Remove(src)
	..()


/obj/warp_portal
	name = "particularly buff portal"
	icon ='icons/obj/objects.dmi'
	icon_state = "fatportal"
	density = 0
	var/obj/target = null
	anchored = 1.0
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

/obj/warp_portal/Bumped(mob/M as mob|obj)
	SPAWN_DBG(0)
		src.teleport(M)
		return
	return

/obj/warp_portal/HasEntered(AM as mob|obj)
	SPAWN_DBG(0)
		src.teleport(AM)
		return
	return

/obj/warp_portal/New()
	..()
	SPAWN_DBG(0)
		// animate_portal_appear(src)
		playsound(src.loc, "warp", 50, 1, 0.1, 0.7)
		sleep(30 SECONDS)
		qdel(src)

/obj/warp_portal/proc/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effects)) //sparks don't teleport
		return
	if (M.anchored && (!istype(M,/obj/machinery/vehicle)))
		return
	if (istype(M, /mob/dead/aieye))
		return
	if (!( src.target ))
		qdel(src)
		return
	if (ismob(M))
		var/mob/T = M
		boutput(T, "<span class='alert'>You are exposed to some pretty swole strange particles, this can't be good...</span>")
		if(prob(1))
			T.gib()
			T.unlock_medal("Where we're going, we won't need eyes to see", 1)
			return
		else
			T.changeStatus("radiation", rand(50,250), 2)
			if(ishuman(T))
				var/mob/living/carbon/human/H = T
				if (prob(75))
					H:bioHolder:RandomEffect("bad")
				else
					H:bioHolder:RandomEffect("good")
	if (istype(M, /atom/movable))
		animate_portal_tele(src)
		playsound(src.loc, "warp", 50, 1, 0.2, 1.2)
		do_teleport(M, src.target, 1) ///You will appear adjacent to the beacon


