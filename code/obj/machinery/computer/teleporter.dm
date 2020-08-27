/obj/machinery/computer/teleporter
	name = "Teleporter"
	icon_state = "teleport"
	var/obj/item/locked = null
	var/obj/machinery/teleport/portal_generator/linkedportalgen = null
	var/id = null
	desc = "A computer that sets which beacon the connected teleporter attempts to create a portal to."

	lr = 1
	lg = 0.3
	lb = 0.9

/obj/machinery/computer/teleporter/New()
	src.id = text("[]", rand(1000, 9999))
	..()
	return

/obj/machinery/computer/teleporter/attackby(obj/item/W as obj, user as mob)
	if (isscrewingtool(W))
		playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
		if(do_after(user, 20))
			if (src.status & BROKEN)
				boutput(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
				G.set_loc(src.loc)
				var/obj/item/circuitboard/teleporter/M = new /obj/item/circuitboard/teleporter( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)
			else
				boutput(user, "<span class='notice'>You disconnect the monitor.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				var/obj/item/circuitboard/teleporter/M = new /obj/item/circuitboard/teleporter( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)

	else
		return src.attack_hand()

/obj/machinery/computer/teleporter/attack_hand()
	src.add_fingerprint(usr)

	if(status & (NOPOWER|BROKEN))
		return

	if (!src.linkedportalgen)
		usr.show_text("Error: no portal generator detected. Please reinitialize the generator to establish a link.", "red")
		return

	var/list/L = list()
	var/list/areaindex = list()

	for(var/obj/item/device/radio/beacon/R in by_type[/obj/item/device/radio/beacon])
		if (!istype(R, /obj/item/device/radio/beacon/jones))
			var/turf/T = get_turf(R)
			if (!T)	continue
			var/tmpname = T.loc.name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = R

	for (var/obj/item/implant/tracking/I in by_type[/obj/item/implant/tracking])
		if (!I.implanted || !ismob(I.loc))
			continue
		else
			var/mob/M = I.loc
			if (isdead(M))
				if (M.timeofdeath + 6000 < world.time)
					continue
			var/tmpname = M.real_name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = I

	var/desc = input("Please select a location to lock in.", "Locking Computer") as null|anything in L
	if (isnull(desc))
		return
	src.locked = L[desc]
	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='notice'>Locked In</span>", 2)
	playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
	return

// Called by the telegun etc (Convair880).
/obj/machinery/computer/teleporter/proc/check_teleporter()
	if (!src) return 0

	if (!src.linkedportalgen)
		return 0

	var/obj/machinery/teleport/portal_generator/our_gen = src.linkedportalgen
	if (our_gen && (our_gen.find_links() < 2)) // Not linked to a working portal ring.
		return 0

	if (src.status)
		if (src.status & NOPOWER)
			return 2 // No power.
		if (src.status & BROKEN)
			return 0

	if (src.locked)
		return 1 // All good.
	else
		return 3 // Not locked in.

/obj/machinery/computer/teleporter/verb/set_id(t as text)
	set src in oview(1)
	set desc = "ID Tag:"
	set category = "Local"

	if(status & (NOPOWER|BROKEN) || !isliving(usr))
		return
	if (t)
		src.id = t
