#define WIRE_SIGNAL 1
#define WIRE_RECEIVE 2
#define WIRE_TRANSMIT 4
#define TRANSMISSION_DELAY 5

TYPEINFO(/obj/item/device/radio/signaler)
	start_listen_effects = null

/obj/item/device/radio/signaler
	name = "remote signaler"
	desc = "A device used to send a coded signal over a specified frequency, with the effect depending on the device that receives the signal."
	icon_state = "signaller"
	item_state = "signaler"
	w_class = W_CLASS_TINY
	tool_flags = TOOL_ASSEMBLY_APPLIER
	frequency = FREQ_SIGNALER
	has_microphone = FALSE
	var/code = 30
	var/delay = 0
	var/airlock_wire = null

/obj/item/device/radio/signaler/New()
	. = ..()

	src.RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_MANIPULATION, PROC_REF(assembly_manipulation))
	src.RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY, PROC_REF(assembly_application))
	src.RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, PROC_REF(assembly_setup))
	src.RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_STATE, PROC_REF(assembly_get_state))

	// Timer + Assembly-Applier -> Timer/Applier-Assembly
	src.AddComponent(/datum/component/assembly/trigger_applier_assembly)

/obj/item/device/radio/signaler/disposing()
	src.UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_MANIPULATION)
	src.UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY)
	src.UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP)
	src.UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_STATE)

	. = ..()

/obj/item/device/radio/signaler/proc/assembly_manipulation(manipulated_signaler, obj/item/assembly/parent_assembly, mob/user)
	src.AttackSelf(user)

/obj/item/device/radio/signaler/proc/assembly_application(manipulated_signaler, obj/item/assembly/parent_assembly, obj/assembly_target)
	src.send_signal()

/obj/item/device/radio/signaler/proc/assembly_setup(manipulated_signaler, obj/item/assembly/parent_assembly, mob/user, is_build_in)
	src.b_stat = 0

/obj/item/device/radio/signaler/proc/assembly_get_state(manipulated_signaler, obj/item/assembly/parent_assembly)
	return TRUE

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

		else if (src.master && istype(src.master, /obj/item/assembly/radio_bomb))	//Radio-detonated single-tank bombs
			logTheThing(LOG_BOMBING, usr, "signalled a radio on a single-tank bomb at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"] with code [src.code] on freq [src.frequency].")
			message_admins("[key_name(usr)] signalled a radio on a single-tank bomb at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"] with code [src.code] on freq [src.frequency].")
			SEND_SIGNAL(src.master, COMSIG_ITEM_BOMB_SIGNAL_START)

		SPAWN(0)
			var/datum/signal/new_signal = get_free_signal()
			new_signal.source = src
			new_signal.data["message"] = "ACTIVATE"
			src.master.receive_signal(new_signal)


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
