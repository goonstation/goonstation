/obj/machinery/computer/teleporter
	name = "teleporter console"
	icon_state = "teleport"
	circuit_type = /obj/item/circuitboard/teleporter
	var/obj/item/locked = null
	var/obj/machinery/teleport/portal_generator/linkedportalgen = null
	var/list/obj/machinery/teleport/portal_ring/linkedportals = null
	id = null
	desc = "A computer that sets which beacon the connected teleporter attempts to create a portal to."

	light_r =1
	light_g = 0.3
	light_b = 0.9

/obj/machinery/computer/teleporter/New()
	src.id = text("[]", rand(1000, 9999))
	for(var/obj/machinery/teleport/portal_ring/ring in orange(2,src))
		ring.find_links()
	..()

/obj/machinery/computer/teleporter/disposing()
	if(src.linkedportalgen)
		src.linkedportalgen.linked_computer = null
		src.linkedportalgen = null
	for(var/obj/machinery/teleport/portal_ring/P in src.linkedportals)
		P.update_target_item_stuff(FALSE)
		P.linked_computer = null
	src.linkedportalgen = null
	src.linkedportals = null
	src.locked = null
	..()

/obj/machinery/computer/teleporter/attack_hand()
	src.add_fingerprint(usr)

	if(status & (NOPOWER|BROKEN))
		return

	if (!src.linkedportalgen)
		usr.show_text("Error: no portal generator detected. Please reinitialize the generator to establish a link.", "red")
		return

	var/list/L = list()
	var/list/areaindex = list()

	for_by_tcl(R, /obj/item/device/radio/beacon)
		var/turf/T = get_turf(R)
		if (!T)	continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = R

	for_by_tcl(I, /obj/item/implant/tracking)
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

	var/desc = tgui_input_list(usr, "Please select a location to lock in.", "Locking Computer", sortList(L, /proc/cmp_text_asc))
	if (isnull(desc))
		return
	if(src.locked)
		for(var/obj/machinery/teleport/portal_ring/P in src.linkedportals)
			P.update_target_item_stuff(FALSE)
	src.locked = L[desc]
	for(var/obj/machinery/teleport/portal_ring/P in src.linkedportals)
		P.update_target_item_stuff(P.on)
	for(var/mob/O in hearers(src, null))
		O.show_message(SPAN_NOTICE("Locked In"), 2)
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
