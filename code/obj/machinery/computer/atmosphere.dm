/*CONTENTS
Gas Sensor
Siphon computer
Mixer Control
*/

/obj/machinery/computer/atmosphere
	name = "atmos"

	light_r =0.85
	light_g = 0.86
	light_b = 1

/obj/machinery/computer/atmosphere/siphonswitch
	name = "area air control"
	icon_state = "atmos"
	var/otherarea
	var/area/area

/obj/machinery/computer/atmosphere/siphonswitch/mastersiphonswitch
	name = "Master Air Control"

#define MAX_PRESSURE 20 * ONE_ATMOSPHERE
/obj/machinery/computer/atmosphere/mixercontrol
	name = "Gas Mixer Control"
	icon_state = "atmos"
	var/obj/machinery/atmospherics/trinary/mixer/mixerid
	var/mixer_information
	req_access = list(access_engineering_engine, access_tox_storage)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	//circuit_type = /obj/item/circuitboard/air_management <This board didn't even lead here what the fuck
	var/last_change = 0
	var/message_delay = 600

	frequency = FREQ_AIR_ALARM_CONTROL

	New()
		..()
		src.AddComponent( \
			/datum/component/packet_connected/radio, \
			null, \
			frequency, \
			null, \
			"receive_signal", \
			FALSE, \
			"mixercontrol", \
			FALSE \
	)

	special_deconstruct(obj/computerframe/frame as obj)
		frame.circuit.frequency = src.frequency

	attack_hand(mob/user)
		if(status & (BROKEN | NOPOWER))
			return

		ui_interact(user)

	receive_signal(datum/signal/signal)
		//boutput(world, "[id] actually can receive a signal!")
		if(!signal || signal.encryption) return

		var/id_tag = signal.data["tag"]
		if(!id_tag || mixerid != id_tag) return

		//boutput(world, "[id] received a signal from [id_tag]!")
		mixer_information = signal.data

		tgui_process.update_uis(src)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "GasMixer")
			ui.open()

	ui_data(mob/user)
		. = ..()
		.["name"] = name
		.["mixerid"] = mixerid
		.["MAX_PRESSURE"] = MAX_PRESSURE
		.["mixer_information"] = mixer_information
		.["allowed"] = src.allowed(user)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()

		if (!src.allowed(usr))
			boutput(usr, SPAN_ALERT("Access denied!"))
			return FALSE

		var/datum/signal/signal = get_free_signal()
		if (!signal || !istype(signal))
			return FALSE

		signal.transmission_method = 1 //radio
		signal.source = src
		signal.data["tag"] = id

		switch (action)
			if ("toggle_pump")
				var/status = mixer_information["pump_status"]
				var/command
				if (status)
					if (status == "Offline")
						command = "power_on"
					else if (status == "Online")
						command = "power_off"

				if (command)
					signal.data["command"] = "toggle_pump"
					signal.data["parameter"] = command

			if ("pressure_set")
				var/target_pressure = params["target_pressure"]
				if ((BOUNDS_DIST(src, usr) > 0 && !issilicon(usr)) || !isliving(usr) || iswraith(usr) || isintangible(usr))
					return FALSE
				if (is_incapacitated(usr) || usr.restrained())
					return FALSE
				if (!src.allowed(usr))
					boutput(usr, SPAN_ALERT("Access denied!"))
					return FALSE
				if (!isnum_safe(target_pressure))
					return FALSE

				var/amount = clamp(target_pressure, 0, MAX_PRESSURE)

				signal.data["command"] = "set_pressure"
				signal.data["parameter"] = num2text(amount)

			if ("ratio")
				signal.data["command"] = "set_ratio"
				signal.data["parameter"] = params["ratio"]

				if (src.id == "pmix_control")
					if (((src.last_change + src.message_delay) <= world.time))
						src.last_change = world.time
						logTheThing(LOG_STATION, usr, "has just edited the plasma mixer at [log_loc(src)].")
						message_admins("[key_name(usr)] has just edited the plasma mixer at at [log_loc(src)].")

			if ("refresh_status")
				signal.data["status"] = 1

		if (signal)
			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)
			. = TRUE

#undef MAX_PRESSURE

