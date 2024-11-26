#define WIRE_SIGNAL 1
#define WIRE_RECEIVE 2
#define WIRE_TRANSMIT 4
#define TRANSMISSION_DELAY 5

/obj/item/device/radio/signaler
	name = "remote signaler"
	desc = "A device used to send a coded signal over a specified frequency, with the effect depending on the device that receives the signal."
	icon_state = "signaller"
	item_state = "signaler"
	w_class = W_CLASS_TINY
	frequency = FREQ_SIGNALER
	has_microphone = FALSE
	start_listen_effects = null
	var/code = 30
	var/delay = 0
	var/airlock_wire = null

/obj/item/device/radio/signaler/receive_signal(datum/signal/signal)
	if (!(src.wires & WIRE_RECEIVE) || !signal || !signal.data || ("[signal.data["code"]]" != "[code]"))
		return

	for (var/mob/M in hearers(1, src.loc))
		M.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)

	if (!(src.wires & WIRE_SIGNAL))
		return

	if (istype(src.loc, /obj/machinery/door/airlock) && src.airlock_wire)
		var/obj/machinery/door/airlock/A = src.loc
		A.pulse(src.airlock_wire)

	if (src.master)
		var/turf/T = get_turf(src.master)
		if (src.master && istype(src.master, /obj/item/device/transfer_valve))
			logTheThing(LOG_BOMBING, usr, "signalled a radio on a tank transfer valve at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"] with code [src.code] on freq [src.frequency].")
			message_admins("[key_name(usr)] signalled a radio on a tank transfer valve at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"] with code [src.code] on freq [src.frequency].")
			SEND_SIGNAL(src.master, COMSIG_ITEM_BOMB_SIGNAL_START)

		else if (src.master && istype(src.master, /obj/item/assembly/rad_ignite)) //Radio-detonated beaker assemblies
			var/obj/item/assembly/rad_ignite/RI = src.master
			logTheThing(LOG_BOMBING, usr, "signalled a radio on a radio-igniter assembly at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"] with code [src.code] on freq [src.frequency]. Contents: [log_reagents(RI.part3)]")
			SEND_SIGNAL(src.master, COMSIG_ITEM_BOMB_SIGNAL_START)

		else if (src.master && istype(src.master, /obj/item/assembly/radio_bomb))	//Radio-detonated single-tank bombs
			logTheThing(LOG_BOMBING, usr, "signalled a radio on a single-tank bomb at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"] with code [src.code] on freq [src.frequency].")
			message_admins("[key_name(usr)] signalled a radio on a single-tank bomb at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"] with code [src.code] on freq [src.frequency].")
			SEND_SIGNAL(src.master, COMSIG_ITEM_BOMB_SIGNAL_START)

		SPAWN(0)
			src.master.receive_signal(signal)


/obj/item/device/radio/signaler/proc/send_signal(message = "ACTIVATE")
	if (src.last_transmission && (world.time <= (last_transmission + TRANSMISSION_DELAY * 2)))
		return

	src.last_transmission = world.time

	if (!(src.wires & WIRE_TRANSMIT))
		return

	logTheThing(LOG_SIGNALERS, !usr && src.master ? src.master.fingerprintslast : usr, "used remote signaller[src.master ? " (connected to [src.master.name])" : ""] at [src.master ? "[log_loc(src.master)]" : "[log_loc(src)]"]. Frequency: [format_frequency(frequency)]/[code].")

	var/datum/signal/signal = get_free_signal()
	signal.source = src
	signal.data["code"] = code
	signal.data["message"] = message

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, src.frequency)

/obj/item/device/radio/signaler/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/instrument/bikehorn))
		var/obj/item/assembly/radio_horn/horn_assembly = new /obj/item/assembly/radio_horn(user)
		W.set_loc(horn_assembly)
		horn_assembly.part2 = W
		W.layer = initial(W.layer)
		user.u_equip(W)
		user.put_in_hand_or_drop(horn_assembly)
		W.master = horn_assembly
		src.master = horn_assembly
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(horn_assembly)
		horn_assembly.part1 = src
		src.add_fingerprint(user)
		boutput(user, "You open the signaller and cram the [W.name] in there!")

	else
		. = ..()

/obj/item/device/radio/signaler/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if (.)
		return

	switch (action)
		if ("set-code")
			var/newcode = text2num_safe(params["value"])
			newcode = round(newcode)
			newcode = min(100, newcode)
			src.code = max(1, newcode)
			. = TRUE

		if ("send")
			src.send_signal("ACTIVATE")

/obj/item/device/radio/signaler/ui_data(mob/user)
	. = ..()
	. += list(
		"code" = src.code,
		"sendButton" = TRUE,
		)


#undef WIRE_SIGNAL
#undef WIRE_RECEIVE
#undef WIRE_TRANSMIT
#undef TRANSMISSION_DELAY
