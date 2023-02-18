///Warp Beacons and Wormholes
///Used by spaceships to travel to other Z-planes

/obj/warp_beacon
	name = "warp beacon"
	desc = "Part of an elaborate small-ship teleportation network recently deployed by Nanotrasen.  Probably won't cause you to die."
	icon = 'icons/obj/ship.dmi'
	icon_state = "beacon"
	anchored = 1
	density = 1
	var/packable = 0
	var/obj/deployer = /obj/beacon_deployer
	var/beaconid //created by kits
	var/encrypted = FALSE

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

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W))
			if (!packable)
				boutput(user,"This beacon's retraction hardware is locked into place and can't be altered.")
				return
			src.visible_message("<b>[user.name]</b> undeploys [src].")
			playsound(src, 'sound/items/Ratchet.ogg', 40, 1)
			src.startpack()
		else if (ispulsingtool(W))
			if (!packable)
				boutput(user,"This beacon's designation circuits are hard-wired and can't be altered.")
				return
			var/str = html_encode(input(user,"Set designation","Re-Designate Buoy","") as null|text)
			if (!str || !length(str))
				boutput(user, "<span style=\"color:red\">No valid input detected.</span>")
				return
			if (length(str) > 30)
				boutput(user, "<span style=\"color:red\">Text too long.</span>")
				return
			src.beaconid = "[str]"
			src.name = "Buoy [beaconid]"
			boutput(user, "<span style=\"color:blue\">Designation updated to 'Buoy [str]'.</span>")
		else
			..()

/obj/warp_beacon/New()
	..()
	START_TRACKING
	AddComponent(/datum/component/minimap_marker, MAP_SYNDICATE, "portal")

/obj/warp_beacon/disposing()
	..()
	STOP_TRACKING

/obj/warp_portal
	name = "particularly buff portal"
	icon ='icons/obj/objects.dmi'
	icon_state = "fatportal"
	density = 0
	var/obj/target = null
	anchored = 1
	event_handler_flags = USE_FLUID_ENTER

/obj/warp_portal/Bumped(mob/M as mob|obj)
	SPAWN(0)
		src.teleport(M)
		return
	return

/obj/warp_portal/Crossed(atom/movable/AM as mob|obj)
	..()
	SPAWN(0)
		src.teleport(AM)

/obj/warp_portal/New()
	..()
	SPAWN(0)
		// animate_portal_appear(src)
		playsound(src.loc, "warp", 50, 1, 0.1, 0.7)
		sleep(30 SECONDS)
		qdel(src)

/obj/warp_portal/proc/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effects)) //sparks don't teleport
		return
	if (M.anchored && (!istype(M,/obj/machinery/vehicle)))
		return
	if (isAIeye(M))
		return
	if (!( src.target ))
		animate(src, time=0.2 SECONDS, transform=matrix(1.25, 0, 0, 0, 1.25, 0), alpha=100, easing=SINE_EASING)
		animate(time=0.2 SECONDS, transform=null, alpha=initial(src.alpha), easing=SINE_EASING)
		return
	if (ismob(M))
		var/mob/T = M
		if (!issilicon(M)) // Borgs don't care about rads (for the meantime)
			boutput(T, "<span class='alert'>You are exposed to some pretty swole strange particles, this can't be good...</span>")

		if(prob(1))
			T.gib()
			T.unlock_medal("Where we're going, we won't need eyes to see", 1)
			logTheThing(LOG_COMBAT, T, "entered [src] at [log_loc(src)] and gibbed")
			return
		else
			T.take_radiation_dose(rand()*1 SIEVERTS)
			if(ishuman(T))
				var/mob/living/carbon/human/H = T
				if (prob(75))
					H:bioHolder:RandomEffect("bad")
				else
					H:bioHolder:RandomEffect("good")
			logTheThing(LOG_COMBAT, T, "entered [src] at [log_loc(src)], got irradiated and teleported to [log_loc(src.target)]")
	if (istype(M, /atom/movable))
		animate_portal_tele(src)
		playsound(src.loc, "warp", 50, 1, 0.2, 1.2)
		do_teleport(M, src.target, 1) ///You will appear adjacent to the beacon

/obj/warp_beacon/proc/startpack()
	src.packable = 0
	src.icon_state = "beaconpack"
	SPAWN(14) //wait until packing is complete
		var/obj/beacon_deployer/packitup = new src.deployer(src.loc)
		playsound(src, 'sound/machines/heater_off.ogg', 20, 1)
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
	var/tile_range = 2
	var/deploying = null
	var/beaconid = null

	New()
		src.beaconid = rand(1000,9999)
		src.name = "warp buoy unit [beaconid]"
		..()

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W) && !src.deploying)
			for (var/turf/T in range(src.tile_range,src))
				if (!T.allows_vehicles)
					boutput(user,"<span style=\"color:red\">The area surrounding the beacon isn't sufficiently navigable for vehicles.</span>")
					return
			if (isrestrictedz(src.z))
				boutput(user, "<span style=\"color:red\">The beacon can't connect to the warp network.</span>")
				return
			src.visible_message("<b>[user.name]</b> deploys [src].")
			playsound(src, 'sound/items/Ratchet.ogg', 40, 1)
			src.deploying = 1
			src.deploybeacon()

		else if (ispulsingtool(W) && !src.deploying)
			var/str = html_encode(input(user,"Set designation","Re-Designate Buoy","") as null|text)
			if (!str || !length(str))
				boutput(user, "<span style=\"color:red\">No valid input detected.</span>")
				return
			if (length(str) > 30)
				boutput(user, "<span style=\"color:red\">Text too long.</span>")
				return
			src.beaconid = "[str]"
			src.name = "warp buoy unit [beaconid]"
			boutput(user, "<span style=\"color:blue\">Designation updated to 'Buoy [str]'.</span>")
		else
			..()

/obj/beacon_deployer/proc/deploybeacon()
	src.icon_state = "beacondeploy"
	src.anchored = 1
	SPAWN(16) //wait until unpacking is complete
		var/obj/warp_beacon/depbeac = new /obj/warp_beacon/deployed(src.loc)
		playsound(src, 'sound/machines/heater_off.ogg', 20, 1)
		depbeac.name = "Buoy [src.beaconid]"
		depbeac.beaconid = src.beaconid
		depbeac.deployer = src.type
		qdel(src)

/obj/beacon_deployer/sketchy
	name = "unregistered warp buoy unit"
	tile_range = 1

	New()
		src.beaconid = rand(1000,9999)
		src.name = "unregistered warp buoy unit [beaconid]"
		desc = "A compact anchor for teleportation technology, cobbled together from spare parts. Looks like the safety features have been laxened."
		..()


/obj/beacon_deployer/syndicate
	name = "syndicate warp buoy unit"

	New()
		src.beaconid = rand(1000,9999)
		src.name = "syndicate warp buoy unit [beaconid]"
		..()

/obj/beaconkit
	name = "warp buoy frame"
	desc = "A partially completed frame for a deployable warp buoy. It's missing rods for its stand."
	icon = 'icons/obj/ship.dmi'
	icon_state = "beacframe_1"
	density = 1
	var/state = 1

	attackby(var/obj/item/I, var/mob/user)
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
		if (beacon == null || the_tool == null || owner == null || BOUNDS_DIST(owner, beacon) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (beacon.state == 1)
			playsound(beacon, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)
			owner.visible_message("<span class='bold'>[owner]</span> begins installing rods onto \the [beacon].")
		if (beacon.state == 2)
			playsound(beacon, 'sound/items/Deconstruct.ogg', 40, 1)
			owner.visible_message("<span class='bold'>[owner]</span> begins connecting \the [beacon]'s electrical systems.")
		if (beacon.state == 3)
			playsound(beacon, 'sound/effects/zzzt.ogg', 30, 1)
			owner.visible_message("<span class='bold'>[owner]</span> begins soldering \the [beacon]'s wiring into place.")
	onEnd()
		..()
		if (beacon.state == 1)
			beacon.state = 2
			beacon.icon_state = "beacframe_2"
			boutput(owner, "<span class='notice'>You successfully install the framework rods.</span>")
			playsound(beacon, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)

			the_tool.change_stack_amount(-4) //the_tool should be rods

			beacon.desc = "A partially completed frame for a deployable warp buoy. It's missing its wiring."
			return
		if (beacon.state == 2)
			beacon.state = 3
			beacon.icon_state = "beaconunit"
			boutput(owner, "<span class='notice'>You finish wiring together the beacon's electronics.</span>")
			playsound(beacon, 'sound/items/Deconstruct.ogg', 40, 1)

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
			playsound(beacon, 'sound/effects/zzzt.ogg', 40, 1)
			var/turf/T = get_turf(beacon)
			new /obj/beacon_deployer(T)
			qdel(beacon)
			return
