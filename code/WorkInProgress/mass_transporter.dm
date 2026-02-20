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
		if (mtp == src.linked_transporter) continue
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
	density = 1
	anchored = ANCHORED
	var/image/screen_image
	var/image/transport_glow
	var/datum/light/light

	///A nearby computer providing targeting data. Must be present for the mass transporter to operate.
	var/obj/machinery/computer/mass_transport/linked_computer = null

	///Whether an outbound teleport is currently being attempted.
	var/teleport_underway = FALSE
	///Progress to successful teleportation. Three power cycles must successfully complete before transportation.
	var/teleport_progress = 0

	///Once a teleport begins, the selection of target transporter is loaded in from the mass transport control computer.
	var/obj/machinery/mass_transporter/transporting_to = null
	///If another mass transporter is attempting to reach this transporter, it cannot initiate an outbound connection.
	var/inbound_in_progress = FALSE

	///Mobs must remain still on the pad between cycles two and three or risk damage to life and limb.
	var/list/mobs_being_sent = list()

	New()
		..()
		START_TRACKING
		src.find_link()
		light = new /datum/light/point
		light.set_brightness(0.6)
		light.set_color(1, 0.2, 0)
		light.attach(src)

		src.screen_image = image('icons/obj/stationobjs.dmi', "mass_transporter_screen")
		screen_image.plane = PLANE_OVERLAY_EFFECTS
		screen_image.blend_mode = BLEND_ADD
		src.AddOverlays(screen_image, "screen_image")

		src.transport_glow = image('icons/obj/stationobjs.dmi', "mass_transporter_glow")
		transport_glow.plane = PLANE_OVERLAY_EFFECTS
		transport_glow.blend_mode = BLEND_ADD

	disposing()
		STOP_TRACKING
		if(src.transporting_to)
			src.transporting_to.inbound_in_progress = FALSE
		src.transporting_to = null
		src.linked_computer = null
		src.mobs_being_sent = null
		..()

	examine(mob/user)
		. = ..()
		if(src.linked_computer && src.linked_computer.locked_target)
			var/turf/T = get_turf(src.linked_computer.locked_target)
			if (T)
				var/dest_name = T.loc.name
				. += "It's currently set to transport to [dest_name]."

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
		playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
		if (!src.linked_computer && !src.find_link())
			src.visible_message(SPAN_ALERT("<b>[src]</b> intones, \"System error. Location data unavailable.\""))
			return
		if (src.inbound_in_progress)
			src.visible_message(SPAN_ALERT("<b>[src] loudly intones, \"NO GO - INBOUND TRANSPORT - CLEAR PAD.\"</b>"))
			playsound(src.loc, 'sound/machines/pod_alarm.ogg', 30, 0)
			return

		var/obj/machinery/power/apc/local_apc = get_local_apc(src)
		if (!local_apc)
			src.visible_message(SPAN_ALERT("<b>[src]</b> intones, \"System error. No compatible local energy source.\""))
			return
		var/obj/item/cell/apc_cell = local_apc.cell
		if (!apc_cell || apc_cell.charge < (0.9 * apc_cell.maxcharge))
			src.visible_message(SPAN_ALERT("<b>[src]</b> intones, \"System error. Area power controller must exceed 90% charge for initialization.\""))
			return

		if (!linked_computer.locked_target)
			src.visible_message("<b>[src]</b> intones, \"Unable to initalize transportation - no destination has been set.\"")
			return
		src.transporting_to = linked_computer.locked_target
		src.visible_message("<b>[src]</b> intones, \"Teleportation process beginning. <b>Please remain stationary until teleport completes.</b>\"")
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
			if(status & (BROKEN|NOPOWER) || !src.transporting_to)
				src.conclude_teleport(FALSE)
			power_usage = 100000
			src.teleport_progress++
			if (teleport_progress >= 3)
				src.conclude_teleport(TRUE)
			else
				playsound(src.loc, 'sound/machines/interdictor_operate.ogg', 15, 0, 0, 0.5)
				if (!(src.transporting_to.status & (BROKEN|NOPOWER)))
					playsound(src.transporting_to.loc, 'sound/effects/ship_alert_minor.ogg', 50, 0)
					if (src.teleport_progress == 2)
						src.transporting_to.visible_message(SPAN_ALERT("<b>[src] loudly intones, \"CLEAR PAD - TRANSPORT INBOUND.\"</b>"))
				if (src.teleport_progress == 2)
					for (var/mob/M in orange(1,src))
						src.mobs_being_sent[M.name] = "[M.x]-[M.y]"
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
		src.teleport_progress = 0
		if(completed && src.transporting_to)
			playsound(src.loc, 'sound/effects/teleport.ogg', 35, 0, 0, 0.7)
			src.teleport_some_nerds(src.transporting_to)
		else
			playsound(src.loc, 'sound/machines/interdictor_deactivate.ogg', 15, 0, 0, 1)
		if(src.transporting_to)
			src.transporting_to.inbound_in_progress = FALSE
		src.mobs_being_sent = list()

	proc/teleport_some_nerds(target_transporter)
		var/turf/dest = get_turf(target_transporter)
		for(var/turf/T in orange(1, src))
			var/this_turf_teleporting = FALSE
			var/xdelta = T.x - src.x
			var/destX = dest.x + xdelta
			var/ydelta = T.y - src.y
			var/destY = dest.y + ydelta
			var/turf/offset_target = locate(destX,destY,src.z)
			for(var/atom/movable/AM in T)
				if(AM.anchored || isitem(AM))
					continue
				this_turf_teleporting = TRUE
				animate_teleport(AM)
				if(ismob(AM))
					var/mob/morb = AM
					morb.changeStatus("stunned", 2 SECONDS)
					var/mobpos = "[morb.x]-[morb.y]"
					if (!mobs_being_sent[morb.name] || mobs_being_sent[morb.name] != mobpos)
						src.teleouch(morb)
				use_power(50000)
				SPAWN(6 DECI SECONDS)
					do_teleport(AM,offset_target,FALSE,sparks=FALSE)
			if (this_turf_teleporting)
				SPAWN(4 DECI SECONDS) //offset a little so you don't run into Yourself
					playsound(offset_target.loc, 'sound/impact_sounds/taser_hit.ogg', 20)
					for(var/mob/M in offset_target)
						src.teleouch(M,TRUE)


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

	///Inflict damage upon people using the mass transporter improperly (possible when moving on transmission pad, guaranteed if hit by incoming transport).
	proc/teleouch(var/mob/M,var/telefrag)
		var/ouch_level = 0
		if(telefrag)
			ouch_level = 2
		else if(prob(60))
			ouch_level = 1
			if(prob(30))
				ouch_level = 2

		switch (ouch_level)
			if (0)
				boutput(M,SPAN_ALERT("You feel a little [prob(50) ? "nauseous" : "woozy"]. Probably ought to stay still on the pad."))
			if (1)
				boutput(M,SPAN_ALERT("The teleporter failed to completely compensate for your movement - something hurts..."))
				M.nauseate(3)
				M.change_misstep_chance(15)
				SPAWN(rand(1,4))
					playsound(M.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 10)
					random_brute_damage(M, 6)
			if (2)
				if(telefrag)
					boutput(M,SPAN_ALERT("<B>The incoming teleport collides with you - you're badly hurt!</B>"))
				else
					boutput(M,SPAN_ALERT("<B>The teleporter failed to compensate for your movement - you're badly hurt!</B>"))
				M.nauseate(8)
				M.take_radiation_dose(0.5 SIEVERTS)
				M.change_misstep_chance(30)
				SPAWN(rand(1,4))
					playsound(M.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 20)
					random_brute_damage(M, rand(6,12))
					random_burn_damage(M, rand(6,12))

		if (ouch_level == 2 && istype(M,/mob/living/carbon/human) && prob(50)) // about 9% overall chance to hit this
			var/mob/living/carbon/human/human = M
			var/dethflavor = pick("suddenly vanishes","tears off in the teleport stream","disappears in a flash","violently disintegrates")
			var/limb_ripped = FALSE
			switch(rand(1,4))
				if(1)
					if(human.limbs.l_arm)
						limb_ripped = TRUE
						human.limbs.l_arm.delete()
						human.visible_message(SPAN_ALERT("<B>[human]</B>'s arm [dethflavor]!"))
				if(2)
					if(human.limbs.r_arm)
						limb_ripped = TRUE
						human.limbs.r_arm.delete()
						human.visible_message(SPAN_ALERT("<B>[human]</B>'s arm [dethflavor]!"))
				if(3)
					if(human.limbs.l_leg)
						limb_ripped = TRUE
						human.limbs.l_leg.delete()
						human.visible_message(SPAN_ALERT("<B>[human]</B>'s leg [dethflavor]!"))
				if(4)
					if(human.limbs.r_leg)
						limb_ripped = TRUE
						human.limbs.r_leg.delete()
						human.visible_message(SPAN_ALERT("<B>[human]</B>'s leg [dethflavor]!"))

			if(limb_ripped)
				playsound(human.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 75)
				human.emote("scream")
				human.changeStatus("stunned", 5 SECONDS)
				human.changeStatus("knockdown", 5 SECONDS)
