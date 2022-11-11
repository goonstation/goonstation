/obj/machinery/teleport
	name = "teleport"
	icon = 'icons/obj/teleporter.dmi'
	density = 1
	anchored = 1
	mats = 10
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL

	New()
		..()

/obj/machinery/teleport/portal_ring
	name = "portal ring"
	desc = "Generates a portal which leads to whatever beacon the computer set it to."
	icon_state = "tele0"
	var/obj/machinery/computer/teleporter/linked_computer = null
	var/obj/machinery/teleport/portal_generator/linked_generator = null
	var/datum/light/light
	power_usage = 0

	New()
		..()
		find_links()
		light = new /datum/light/point
		light.set_brightness(0.6)
		light.set_color(0.4, 0.4, 1)
		light.attach(src)

	attack_ai()
		src.Attackhand()

	Bumped(M as mob|obj)
		SPAWN( 0 )
			if (src.icon_state == "tele1")
				teleport(M)
				use_power(5000)
			return
		return

	process()
		if (src.icon_state == "tele1") // REALLY. really. really? r e a l l y?
			power_usage = 5000
		else
			power_usage = 0
		..()
		if (status & NOPOWER)
			icon_state = "tele0"

	proc/teleport(atom/movable/M as mob|obj)
		if (find_links() < 2)
			src.visible_message("<b>[src]</b> intones, \"System error. Cannot find required equipment links.\"")
			return
		if (!linked_computer.locked)
			src.visible_message("<b>[src]</b> intones, \"System error. Cannot verify locked co-ordinates.\"")
			return
		if (istype(M, /atom/movable))
			var/turf/originTurf = get_turf(src)
			var/originArea
			if (originTurf)
				originArea = originTurf.loc
			if (istype(originArea, /area/centcom) || (istype(originArea, /area/shuttle))) // If the origin area is centcom or a shuttle, fail.
				return
			if (!do_teleport(M, linked_computer.locked, 0))
				logTheThing(LOG_COMBAT, M, "entered teleporter portal ring at [log_loc(src)] and teleported to [log_loc(linked_computer.locked)]")
		else
			elecflash(src, power=3)

	proc/find_links()
		linked_computer = null
		linked_generator = null
		var/found = 0
		for(var/obj/machinery/computer/teleporter/T in orange(2,src))
			linked_computer = T
			found++
			break
		for(var/obj/machinery/teleport/portal_generator/S in orange(2,src))
			linked_generator = S
			found++
			break
		return found

/obj/machinery/teleport/portal_generator
	name = "portal generator"
	desc = "This fancy piece of machinery generates the portal. You can flick it on and off."
	icon_state = "controller"
	machine_registry_idx = MACHINES_PORTALGENERATORS
	var/active = 0
	var/engaged = 0
	var/obj/machinery/computer/teleporter/linked_computer = null
	var/list/linked_rings = list()
	power_usage = 250

	New()
		..()
		find_links()

	attack_ai()
		src.Attackhand()

	attack_hand()
		if(engaged)
			src.disengage()
		else
			src.engage()

	attackby(var/obj/item/W)
		src.Attackhand()

	power_change()
		..()
		if(status & NOPOWER)
			icon_state = "controller-p"
			if (istype(linked_computer))
				linked_computer.icon_state = "tele0"
				linked_computer.light.disable()
		else
			icon_state = "controller"

	proc/engage()
		if(status & (BROKEN|NOPOWER))
			return
		if (find_links() < 2)
			src.visible_message("<b>[src]</b> intones, \"System error. Cannot find required equipment links.\"")
			return
		for (var/obj/machinery/teleport/portal_ring/R in linked_rings)
			R.icon_state = "tele1"
			R.light.enable()
		use_power(5000)
		src.visible_message("<b>[src]</b> intones, \"Teleporter engaged.\"")
		src.add_fingerprint(usr)
		src.engaged = 1
		return

	proc/disengage()
		if(status & (BROKEN|NOPOWER))
			return
		if (find_links() < 2)
			src.visible_message("<b>[src]</b> intones, \"System error. Cannot find required equipment links.\"")
			return
		for (var/obj/machinery/teleport/portal_ring/R in linked_rings)
			R.icon_state = "tele0"
			R.light.disable()
		src.visible_message("<b>[src]</b> intones, \"Teleporter disengaged.\"")
		src.add_fingerprint(usr)
		src.engaged = 0
		return

	proc/find_links()
		linked_computer = null
		linked_rings = list()
		var/found = 0
		for(var/obj/machinery/computer/teleporter/T in orange(2,src))
			linked_computer = T
			T.linkedportalgen = src
			found++
			break
		for(var/obj/machinery/teleport/portal_ring/H in orange(2,src))
			linked_rings += H
		if (linked_rings.len > 0) found++
		return found

/proc/do_teleport(atom/movable/M as mob|obj, atom/destination, precision, var/use_teleblocks = 1, var/sparks = 1)
	if(istype(M, /obj/effects))
		qdel(M)
		return 1

	var/turf/destturf = get_turf(destination)
	if (!istype(destturf))
		return 1

	var/tx = destturf.x + rand(precision * -1, precision)
	var/ty = destturf.y + rand(precision * -1, precision)

	var/turf/tmploc

	if (ismob(destination.loc)) //If this is an implant.
		tmploc = locate(tx, ty, destturf.z)
	else
		tmploc = locate(tx, ty, destination.z)

	if(tx == destturf.x && ty == destturf.y && (istype(destination.loc, /obj/storage/closet) || istype(destination.loc, /obj/storage/secure/closet)))
		tmploc = destination.loc

	if(tmploc==null)
		return 1

	var/m_blocked = 0


	for (var/atom/A as anything in by_cat[TR_CAT_TELEPORT_JAMMERS])
		if (IN_RANGE(tmploc, A, GET_ATOM_PROPERTY(A, PROP_ATOM_TELEPORT_JAMMER)))
			m_blocked = 1
			break

	//if((istype(tmploc,/area/wizard_station)) || (istype(tmploc,/area/syndicate_station)))
	var/area/myArea = get_area(tmploc)
	if (myArea?.teleport_blocked || isrestrictedz(tmploc.z) || m_blocked)
		if(use_teleblocks)
			if(isliving(M))
				boutput(M, "<span class='alert'><b>Teleportation failed!</b></span>")
			else
				for(var/mob/thing in M)
					boutput(thing, "<span class='alert'><b>Teleportation failed!</b></span>")
			return 1

	M.set_loc(tmploc)
	if (sparks)
		elecflash(M, power=3)
	return 0

// /mob/living/carbon/human/list_ejectables() looked pretty similar to what I wanted, but this doesn't have organs that you need to live
//drop a non-vital organ or a limb //shamelessly stolen from Harry Potter as is this whole ability
proc/splinch(var/mob/M as mob, var/probability)
	if (prob(probability))
		if (istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			var/part_splinched

			part_splinched = pick("l_arm", "r_arm", "l_leg", "l_leg","left_eye", "right_eye", "left_lung", "right_lung", "butt", "left_kidney", "right_kidney", "spleen", "pancreas", "appendix", "stomach", "intestines", "tail")
			if (part_splinched == "l_arm" || part_splinched == "r_arm" || part_splinched == "l_leg" || part_splinched == "l_leg")
				return H.sever_limb(part_splinched)
			else
				return H.organHolder.drop_organ(part_splinched)

		// owner.visible_message("<span class='alert'><b>[M]</b> splinches themselves and their [part_splinched] falls off!</span>")
