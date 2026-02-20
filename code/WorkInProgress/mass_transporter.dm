/obj/machinery/computer/mass_transport
	name = "mass transporter console"
	icon_state = "teleport"
	circuit_type = /obj/item/circuitboard/mass_transport
	desc = "Configures destination data for a nearby mass transporter."

	///The local mass transporter associated with the computer.
	var/obj/machinery/mass_transporter/linked_transporter = null
	///Holds a destination for the local mass transporter to send things to.
	var/obj/locked_target = null

	light_r = 1
	light_g = 0.3
	light_b = 0.9

/obj/machinery/computer/mass_transport/New()
	for(var/obj/machinery/mass_transporter/mt in orange(2,src))
		mt.find_link()
		break
	..()

/obj/machinery/computer/mass_transport/disposing()
	if(src.linked_transporter)
		src.linked_transporter.linked_computer = null
	src.linked_transporter = null
	src.locked_target = null
	..()


/obj/machinery/computer/mass_transport/attack_hand()
	src.add_fingerprint(usr)

	if(status & (NOPOWER|BROKEN))
		return

	if (!src.linked_transporter)
		usr.show_text("Error: no mass transporter in range.", "red")
		return

	var/list/targetlist = list()
	var/list/areaindex = list()

	for_by_tcl(mtp, /obj/machinery/mass_transporter)
		var/turf/T = get_turf(mtp)
		if (!T)	continue
		var/dest_name = T.loc.name
		if(areaindex[dest_name])
			dest_name = "[dest_name] ([++areaindex[dest_name]])"
		else
			areaindex[dest_name] = 1
		targetlist[dest_name] = mtp

	var/desc = tgui_input_list(usr, "Please select a mass transport destination.", "Mass Transport Routing", sortList(targetlist, /proc/cmp_text_asc))
	if (isnull(desc))
		return
	src.locked_target = targetlist[desc]
	for(var/mob/O in hearers(src, null))
		O.show_message(SPAN_NOTICE("Target selected: [desc]"), 2)
	playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
	return


/obj/machinery/mass_transporter
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mass_transporter"
	name = "mass transporter"
	desc = "A mildly ominous-looking machine capable of simultaneously moving multiple objects over a short distance in space."
	anchored = ANCHORED
	var/image/screen_image
	var/image/transport_glow
	var/datum/light/light

	///A nearby computer providing targeting data. Must be present for the mass transporter to operate.
	var/obj/machinery/computer/mass_transport/linked_computer = null

	///Whether a teleport is currently being attempted.
	var/teleport_underway = FALSE
	///Progress to successful teleportation. Three power cycles must successfully complete before transportation.
	var/teleport_progress = 0

	New()
		..()
		src.find_link()
		light = new /datum/light/point
		light.set_brightness(0.6)
		light.set_color(1, 0.2, 0)
		light.attach(src)

		src.screen_image = image('icons/obj/stationobjs.dmi', "mass_transporter_screen", -1)
		screen_image.plane = PLANE_LIGHTING
		screen_image.blend_mode = BLEND_ADD
		screen_image.layer = LIGHTING_LAYER_BASE
		screen_image.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
		src.AddOverlays(screen_image, "screen_image")

		src.transport_glow = image('icons/obj/stationobjs.dmi', "mass_transporter_glow", -1)
		transport_glow.plane = PLANE_LIGHTING
		transport_glow.blend_mode = BLEND_ADD
		transport_glow.layer = LIGHTING_LAYER_BASE

	attack_ai()
		src.Attackhand()

	attack_hand()
		if (!ON_COOLDOWN(src, "interaction_ratelimit", 1 SECOND))
			if (src.teleport_underway)
				src.abort_teleport()
			else
				src.try_activate()

	proc/try_activate()
		if(status & (BROKEN|NOPOWER))
			return
		if (!linked_computer && !src.find_link())
			src.visible_message("<b>[src]</b> intones, \"System error. Location data unavailable.\"")
			return
		src.visible_message("<b>[src]</b> intones, \"Teleportation process beginning. Please remain stationary until teleport completes.\"")
		playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
		src.add_fingerprint(usr)
		src.initialize_teleport()
		return

	proc/abort_teleport()
		if(status & (BROKEN|NOPOWER))
			return
		src.visible_message("<b>[src]</b> intones, \"Teleportation process aborted.\"")
		playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
		src.add_fingerprint(usr)
		src.conclude_teleport(FALSE)
		return

	process()
		if (src.teleport_underway)
			if(status & (BROKEN|NOPOWER))
				src.conclude_teleport(FALSE)
			power_usage = 8000
			src.teleport_progress++
			if (teleport_progress >= 3)
				src.conclude_teleport(TRUE)
			else
				playsound(src.loc, 'sound/machines/interdictor_operate.ogg', 25, 0, 0, 0.5)
		else
			power_usage = 0
		..()

	power_change()
		..()
		if(status & (BROKEN|NOPOWER))
			if(teleport_underway)
				src.conclude_teleport(FALSE)
			src.ClearSpecificOverlays("screen_image")
		else
			src.AddOverlays(screen_image, "screen_image")

	proc/initialize_teleport()
		src.light.enable()
		src.AddOverlays(transport_glow, "transport_glow")
		src.teleport_underway = TRUE

	proc/conclude_teleport(completed)
		src.light.disable()
		src.ClearSpecificOverlays("transport_glow")
		src.teleport_underway = FALSE
		if(completed && linked_computer.locked_target)
			playsound(src.loc, 'sound/effects/warp1.ogg', 65, 1)
			src.teleport_some_nerds(linked_computer.locked_target)
		else
			playsound(src.loc, 'sound/machines/interdictor_deactivate.ogg', 25, 0, 0, 1)

	proc/teleport_some_nerds(target_transporter)
		var/turf/dest = get_turf(target_transporter)
		for(var/turf/T in orange(1, src))
			var/xdelta = T.x - src.x
			var/destX = dest.x + xdelta
			var/ydelta = T.y - src.y
			var/destY = dest.y + ydelta
			var/offset_target = locate(destX,destY,src.z)
			for(var/atom/movable/AM in T)
				if(AM.anchored)
					continue
				animate_teleport(AM)
				if(ismob(AM))
					var/mob/O = AM
					O.changeStatus("stunned", 2 SECONDS)
				SPAWN(6 DECI SECONDS)
					do_teleport(AM,offset_target,FALSE,sparks=FALSE)

	proc/find_link()
		if(linked_computer)
			LAZYLISTREMOVE(linked_computer.linked_transporter, src)
		linked_computer = null
		var/found = FALSE
		for(var/obj/machinery/computer/mass_transport/mtp in orange(2,src))
			linked_computer = mtp
			linked_computer.linked_transporter = src
			found = TRUE
			break
		return found
