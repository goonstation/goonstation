///Station's transception anrray, used for cargo I/O operations on maps that include one
var/global/obj/machinery/communications_dish/transception/transception_array

//Cost to send or receive. Should be subject to tuning.
#define ARRAY_TELECOST 1500

/obj/machinery/communications_dish/transception
	name = "Transception Array"
	desc = "Sends and receives both energy and matter over considerable distance. Figuratively, but hopefully not literally, duct-taped together."
	icon = 'icons/obj/machines/transception.dmi'
	icon_state = "array"
	bound_height = 64
	bound_width = 96

	///Whether array permits transception; can be disabled temporarily by anti-overload measures, or toggled manually
	var/primed = TRUE
	///Whether array is currently transceiving
	var/is_transceiving = FALSE
	///Beam overlay
	var/obj/overlay/telebeam

	//Failsafe variables
	var/failsafe_enabled = TRUE
	var/failsafe_active = TRUE

	New()
		. = ..()
		src.telebeam = new /obj/overlay/transception_beam()
		src.vis_contents += telebeam
		src.UpdateIcon()
		if(!transception_array)
			transception_array = src

	power_change()
		. = ..()
		src.UpdateIcon()

	process()
		. = ..()
		if(src.failsafe_active)
			if(src.primed) //don't attempt restart if somehow primed while failsafe is online
				src.failsafe_active = FALSE
			else
				src.attempt_restart()

	///Respond to a pad's inquiry of whether a transception can occur
	proc/can_transceive(var/pad_netnum)
		. = FALSE
		if(src.is_transceiving)
			return
		if(!powered() || !src.primed)
			return
		if(src.failsafe_prompt())
			return
		var/datum/powernet/powernet = src.get_direct_powernet()
		var/netnum = powernet.number
		if(netnum != pad_netnum)
			return
		return TRUE

	///Respond to a pad's request to do a transception
	proc/transceive(var/pad_netnum)
		. = FALSE
		if(src.is_transceiving)
			return
		if(!powered() || !src.primed)
			return
		if(src.failsafe_prompt())
			return
		var/datum/powernet/powernet = src.get_direct_powernet()
		var/netnum = powernet.number
		if(netnum != pad_netnum)
			return
		src.is_transceiving = TRUE
		if(!src.use_area_cell_power(200)) //some electrical cost hits the cell directly, for "kick-starting" beam
			return
		use_power(ARRAY_TELECOST)
		playsound(src.loc, "sound/effects/mag_forcewall.ogg", 50, 0)
		flick("beam",src.telebeam)
		SPAWN_DBG(0.1 SECONDS)
			src.is_transceiving = FALSE
		return TRUE

	///Directly discharge power from the area's cell
	proc/use_area_cell_power(var/use_amount)
		var/obj/machinery/power/apc/AC = get_local_apc(src)
		if (!AC)
			return 0
		var/obj/item/cell/C = AC.cell
		if (!C || C.charge < use_amount)
			return 0
		else
			C.use(use_amount)
			return 1

	///If failsafe mode is active, disable primed status if power grows too low and (to be implemented) notify pad terminals of this failure
	proc/failsafe_prompt() //returns true if error
		var/obj/machinery/power/apc/AC = get_local_apc(src)
		if (!AC)
			return
		if (AC && !AC.cell)
			return
		var/obj/item/cell/C = AC.cell
		var/combined_cost = (0.3 * C.maxcharge) + ARRAY_TELECOST
		if (C.charge < combined_cost)
			playsound(src.loc, "sound/effects/manta_alarm.ogg", 50, 1)
			src.primed = FALSE
			src.failsafe_active = TRUE
			src.UpdateIcon()
			. = TRUE
		return

	///Primed status restarts when power is restored
	proc/attempt_restart()
		var/obj/machinery/power/apc/AC = get_local_apc(src)
		if (!AC)
			return
		if (AC && !AC.cell)
			return
		var/obj/item/cell/C = AC.cell
		var/combined_cost = (0.5 * C.maxcharge) + ARRAY_TELECOST
		if (C.charge > combined_cost)
			playsound(src.loc, "sound/effects/manta_interface.ogg", 50, 1)
			src.primed = TRUE
			src.failsafe_active = FALSE
			src.UpdateIcon()
			. = TRUE
		return

	ex_act(severity) //tbi: damage and repair
		return

#undef ARRAY_TELECOST

/obj/machinery/communications_dish/transception/update_icon()
	if(powered())
		var/primed_state = "allquiet"
		if(src.primed)
			primed_state = "glow_primed"

		var/image/glowy = SafeGetOverlayImage("glows", 'icons/obj/machines/transception.dmi', "glow_online")
		glowy.plane = PLANE_ABOVE_LIGHTING
		UpdateOverlays(glowy, "glows", 0, 1)

		var/image/primer = SafeGetOverlayImage("primed", 'icons/obj/machines/transception.dmi', primed_state)
		primer.plane = PLANE_ABOVE_LIGHTING
		UpdateOverlays(primer, "primed", 0, 1)
	else
		ClearAllOverlays()

/obj/overlay/transception_beam
	icon = 'icons/obj/machines/transception.dmi'
	icon_state = "allquiet"
	plane = PLANE_ABOVE_LIGHTING

/obj/machinery/networked/transception_pad
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "neopad"
	name = "transception pad"
	anchored = 1
	density = 0
	layer = FLOOR_EQUIP_LAYER1
	mats = 16
	timeout = 10
	desc = "A sophisticated cargo pad capable of utilizing the station's transception antenna when connected by cable. Keep clear during operation."
	device_tag = "PNET_CARGONODE"
	var/is_transceiving = FALSE

	attack_hand(mob/user) //placeholder for netop
		src.attempt_transceive()
		return

	attackby(obj/item/W, mob/user) //placeholder for netop
		if(istype(W,/obj/item/device/calibrator))
			var/cargotarget = input(usr,"TEMPORARY INTERFACE","Select Target",null) in shippingmarket.pending_crates
			if(cargotarget)
				src.attempt_transceive(cargotarget)
			return
		else
			..()

	proc/attempt_transceive(var/inbound_target = FALSE)
		if(src.is_transceiving)
			return
		if(!transception_array)
			return
		var/datum/powernet/powernet = src.get_direct_powernet()
		if(!powernet)
			return
		var/netnum = powernet.number
		if(transception_array.can_transceive(netnum) == FALSE)
			return
		if(inbound_target)
			receive_a_thing(netnum,inbound_target)
		else
			send_a_thing(netnum)
		return

	proc/send_a_thing(var/netnumber)
		src.is_transceiving = TRUE
		playsound(src.loc, "sound/effects/ship_alert_minor.ogg", 50, 0) //incoming cargo warning (stand clear)
		SPAWN_DBG(2 SECONDS)
			flick("neopad_activate",src)
			SPAWN_DBG(0.3 SECONDS)
				var/atom/movable/thing2send
				var/list/oofed_nerds = list()
				for(var/atom/movable/O as obj|mob in src.loc)
					if(O.anchored) continue
					if(O == src) continue
					if(istype(O,/mob)) //no mobs
						if(istype(O,/mob/living/carbon/human) && prob(15))
							oofed_nerds += O
						continue
					if(istype(O,/obj/storage/crate))
						thing2send = O
						break //only one thing at a time!

				if(thing2send && transception_array.transceive(netnumber))
					for(var/nerd in oofed_nerds)
						telefrag(nerd) //did I mention NO MOBS
					thing2send.loc = src
					SPAWN_DBG(1 SECOND)
						shippingmarket.sell_crate(thing2send)

					showswirl(src.loc)
					use_power(200) //most cost is at the array
				src.is_transceiving = FALSE

		return

	proc/receive_a_thing(var/netnumber,var/atom/movable/thing2get)
		src.is_transceiving = TRUE
		playsound(src.loc, "sound/effects/ship_alert_minor.ogg", 50, 0) //incoming cargo warning (stand clear)
		SPAWN_DBG(2 SECONDS)
			flick("neopad_activate",src)
			SPAWN_DBG(0.4 SECONDS)
				if(thing2get in shippingmarket.pending_crates && transception_array.transceive(netnumber))
					shippingmarket.pending_crates.Remove(thing2get)
					for(var/atom/movable/O as mob in src.loc)
						if(istype(O,/mob/living/carbon/human) && prob(15))
							telefrag(O) //get out the way
					thing2get.loc = src.loc

					showswirl(src.loc)
					use_power(200) //most cost is at the array
				src.is_transceiving = FALSE

		return

	///Standing on the pad while it's trying to transport cargo is an extremely dumb idea, prepare to get owned
	proc/telefrag(var/mob/living/carbon/human/M)
		var/dethflavor = pick("suddenly vanishes","tears off in the teleport stream","disappears in a flash","violently disintegrates")

		switch(rand(1,4))
			if(1)
				if(M.limbs.l_arm)
					M.limbs.l_arm.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s arm [dethflavor]!</span>")
			if(2)
				if(M.limbs.r_arm)
					M.limbs.r_arm.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s arm [dethflavor]!</span>")
			if(3)
				if(M.limbs.l_leg)
					M.limbs.l_leg.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s leg [dethflavor]!</span>")
			if(4)
				if(M.limbs.r_leg)
					M.limbs.r_leg.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s leg [dethflavor]!</span>")

		playsound(M.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 75)
		M.emote("scream")
		M.changeStatus("stunned", 5 SECONDS)
		M.changeStatus("weakened", 5 SECONDS)
