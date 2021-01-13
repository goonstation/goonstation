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
	var/packable = 0
	var/beaconid //created by kits

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
	deployed
		packable = 1

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/wrench))
			if (!packable)
				boutput(usr,"This beacon's retraction hardware is locked into place and can't be altered.")
				return
			src.visible_message("<b>[user.name]</b> undeploys [src].")
			playsound(get_turf(src), "sound/items/Ratchet.ogg", 40, 1)
			src.startpack()
		else if (istype(W, /obj/item/device/multitool))
			if (!packable)
				boutput(usr,"This beacon's designation circuits are hard-wired and can't be altered.")
				return
			var/str = input(usr,"Set designation","Re-Designate Buoy","") as null|text
			if (!str || !length(str))
				boutput(usr, "<span style=\"color:red\">No valid input detected.</span>")
				return
			if (length(str) > 30)
				boutput(usr, "<span style=\"color:red\">Text too long.</span>")
				return
			src.beaconid = "[str]"
			src.name = "Buoy [beaconid]"
			boutput(usr, "<span style=\"color:blue\">Designation updated to 'Buoy [str]'.</span>")
		else
			..()

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

/obj/warp_beacon/proc/startpack()
	src.packable = 0
	src.icon_state = "beaconpack"
	SPAWN_DBG(14) //wait until packing is complete
		var/obj/beacon_deployer/packitup = new /obj/beacon_deployer(src.loc)
		playsound(get_turf(src), "sound/machines/heater_off.ogg", 20, 1)
		if(src.beaconid)
			packitup.beaconid = src.beaconid
			packitup.name = "warp buoy unit [beaconid]"
		qdel(src)

//deployable warp beacon

/obj/beacon_deployer
	name = "warp buoy unit"
	desc = "A compact anchor for teleportation technology, held together by cut-rate construction supplies. What could possibly go wrong?"
	icon = 'icons/obj/ship.dmi'
	icon_state = "beaconunit"
	density = 1
	var/deploying = null
	var/beaconid = null

	New()
		src.beaconid = rand(1000,9999)
		src.name = "warp buoy unit [beaconid]"
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/wrench) && !src.deploying)
			for (var/turf/T in range(2,src))
				if (!T.allows_vehicles)
					boutput(usr,"<span style=\"color:red\">The area surrounding the beacon isn't sufficiently navigable for vehicles.</span>")
					return
			if (isrestrictedz(src.z))
				boutput(usr, "<span style=\"color:red\">The beacon can't connect to the warp network.</span>")
				return
			src.visible_message("<b>[user.name]</b> deploys [src].")
			playsound(get_turf(src), "sound/items/Ratchet.ogg", 40, 1)
			src.deploying = 1
			src.deploybeacon()

		else if (istype(W, /obj/item/device/multitool/) && !src.deploying)
			var/str = input(usr,"Set designation","Re-Designate Buoy","") as null|text
			if (!str || !length(str))
				boutput(usr, "<span style=\"color:red\">No valid input detected.</span>")
				return
			if (length(str) > 30)
				boutput(usr, "<span style=\"color:red\">Text too long.</span>")
				return
			src.beaconid = "[str]"
			src.name = "warp buoy unit [beaconid]"
			boutput(usr, "<span style=\"color:blue\">Designation updated to 'Buoy [str]'.</span>")
		else
			..()

/obj/beacon_deployer/proc/deploybeacon()
	src.icon_state = "beacondeploy"
	src.anchored = 1
	SPAWN_DBG(16) //wait until unpacking is complete
		var/obj/warp_beacon/depbeac = new /obj/warp_beacon/deployed(src.loc)
		playsound(get_turf(src), "sound/machines/heater_off.ogg", 20, 1)
		depbeac.name = "Buoy [src.beaconid]"
		depbeac.beaconid = src.beaconid
		qdel(src)

/obj/beaconkit
	name = "warp buoy frame"
	desc = "A partially completed frame for a deployable warp buoy. It's missing rods for its stand."
	icon = 'icons/obj/ship.dmi'
	icon_state = "beacframe_1"
	density = 1
	var/state = 1

	attackby(var/obj/item/I as obj, var/mob/user as mob)
		switch(state)
			if(1)
				if (istype(I, /obj/item/rods))
					if (I.amount < 4)
						boutput(user, "<span style=\"color:red\">You don't have enough rods to complete the stand (4 required).</span>")
					else
						actions.start(new /datum/action/bar/icon/warp_beacon_assembly(src, I, 2 SECONDS), user)
			if(2)
				if (istype(I, /obj/item/cable_coil))
					actions.start(new /datum/action/bar/icon/warp_beacon_assembly(src, I, 2 SECONDS), user)
			if(3)
				if (istype(I, /obj/item/electronics/soldering))
					actions.start(new /datum/action/bar/icon/warp_beacon_assembly(src, I, 2 SECONDS), user)

/datum/action/bar/icon/warp_beacon_assembly
	id = "warp_beacon_assembly"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 2 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/beaconkit/beacon
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			beacon = O
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (beacon == null || the_tool == null || owner == null || get_dist(owner, beacon) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (beacon.state == 1)
			playsound(get_turf(beacon), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
			owner.visible_message("<span class='bold'>[owner]</span> begins installing rods onto \the [beacon].")
		if (beacon.state == 2)
			playsound(get_turf(beacon), "sound/items/Deconstruct.ogg", 40, 1)
			owner.visible_message("<span class='bold'>[owner]</span> begins connecting \the [beacon]'s electrical systems.")
		if (beacon.state == 3)
			playsound(get_turf(beacon), "sound/effects/zzzt.ogg", 30, 1)
			owner.visible_message("<span class='bold'>[owner]</span> begins soldering \the [beacon]'s wiring into place.")
	onEnd()
		..()
		if (beacon.state == 1)
			beacon.state = 2
			beacon.icon_state = "beacframe_2"
			boutput(owner, "<span class='notice'>You successfully install the framework rods.</span>")
			playsound(get_turf(beacon), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)

			the_tool.amount -= 4
			if (the_tool.amount < 1)
				var/mob/source = owner
				source.u_equip(the_tool)
				qdel(the_tool)
			else if(the_tool.inventory_counter)
				the_tool.inventory_counter.update_number(the_tool.amount)

			beacon.desc = "A partially completed frame for a deployable warp buoy. It's missing its wiring."
			return
		if (beacon.state == 2)
			beacon.state = 3
			beacon.icon_state = "beaconunit"
			boutput(owner, "<span class='notice'>You finish wiring together the beacon's electronics.</span>")
			playsound(get_turf(beacon), "sound/items/Deconstruct.ogg", 40, 1)

			the_tool.amount -= 1
			if (the_tool.amount < 1)
				var/mob/source = owner
				source.u_equip(the_tool)
				qdel(the_tool)
			else if(the_tool.inventory_counter)
				the_tool.inventory_counter.update_number(the_tool.amount)

			beacon.desc = "A nearly-complete frame for a deployable warp buoy. Its connections haven't been soldered together."
			return
		if (beacon.state == 3)
			boutput(owner, "<span class='notice'>You solder the wiring into place, completing the beacon. It's now ready to deploy with a wrench.</span>")
			playsound(get_turf(beacon), "sound/effects/zzzt.ogg", 40, 1)
			var/turf/T = get_turf(beacon)
			new /obj/beacon_deployer(T)
			qdel(beacon)
			return
