//
// Alarm
//

/obj/machinery/alarm
	name = "Air Monitor"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm0"
	anchored = 1
	var/skipprocess = 0 //Experimenting
	var/alarm_frequency = FREQ_ALARM
	var/alarm_zone = null
	var/control_frequency = FREQ_AIR_ALARM_CONTROL
	var/id
	var/locked = 1

	var/datum/gas_mixture/environment
	var/safe
	/*var/panic_mode = 0 */
	var/e_gas = 0
	var/last_safe = 2

/obj/machinery/alarm/New()
	..()
	MAKE_SENDER_RADIO_PACKET_COMPONENT("alarm", alarm_frequency)
	MAKE_SENDER_RADIO_PACKET_COMPONENT("control", control_frequency) // seems to be unused?

	if(!alarm_zone)
		var/area/A = get_area(loc)
		if(A.name)
			alarm_zone = A.name
		else
			alarm_zone = "Unregistered"

/obj/machinery/alarm/process()
	src.updateDialog()
	/*
	if (panic_mode > 0)
		panic_mode--
		if(panic_mode <= 0)
			unpanic()
	*/
	if (src.skipprocess)
		src.skipprocess--
		return

	var/turf/location = src.loc
	safe = 2

	if(status & (NOPOWER|BROKEN))
		icon_state = "alarmp"
		return

	use_power(5, ENVIRON)

	if (!( istype(location, /turf) ))
		return 0

	environment = location.return_air()

	if (!istype(environment))
		safe = -1
		return

	var/environment_pressure = MIXTURE_PRESSURE(environment)

	if((environment_pressure < ONE_ATMOSPHERE*0.9) || (environment_pressure > ONE_ATMOSPHERE*1.1))
		//Pressure sensor
		if((environment_pressure < ONE_ATMOSPHERE*0.8) || (environment_pressure > ONE_ATMOSPHERE*1.2))
			safe = 0
		else safe = 1

	if(safe && ((environment.oxygen < MOLES_O2STANDARD*0.9) || (environment.oxygen > MOLES_O2STANDARD*1.1)))
		//Oxygen Levels Sensor
		if(environment.oxygen < MOLES_O2STANDARD*0.8)
			safe = 0
		else safe = 1

	if(safe && ((environment.temperature < (T0C)) || (environment.temperature > (T0C+40))))
		//Oxygen Levels Sensor
		if((environment.temperature < (T0C-10)) || (environment.temperature > (T0C+50)))
			safe = 0
		else safe = 1

	if(safe && (environment.carbon_dioxide > 0.05))
		//CO2 Levels Sensor
		if(environment.carbon_dioxide > 0.1)
			safe = 0
		else safe = 1

	if(safe && (environment.toxins > 1))
		//Plasma Levels Sensor
		if(environment.toxins > 2)
			safe = 0
		else safe = 1

	var/tgmoles = 0
	if(length(environment.trace_gases))
		for(var/datum/gas/trace_gas as anything in environment.trace_gases)
			tgmoles += trace_gas.moles

	if(tgmoles > 1)
		if(tgmoles > 2)
			safe = 0
		else safe = 1

	src.icon_state = "alarm[!safe]"

	if(safe == 2)
		src.skipprocess = 2

	if(alarm_frequency && last_safe != safe)
		post_alert(safe)
		last_safe = safe

	return

/obj/machinery/alarm/proc/post_alert(alert_level)
	var/datum/signal/alert_signal = get_free_signal()
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = alarm_zone
	alert_signal.data["type"] = "Atmospheric"

	switch (alert_level)
		if (0)
			alert_signal.data["alert"] = "severe"
		if (1)
			alert_signal.data["alert"] = "minor"
		if (2)
			alert_signal.data["alert"] = "reset"

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, alert_signal, null, "alarm")

/obj/machinery/alarm/attackby(var/obj/item/W, user)
	if (issnippingtool(W))
		status ^= BROKEN
		src.add_fingerprint(user)
		src.visible_message("<span class='alert'>[user] has [(status & BROKEN) ? "de" : "re"]activated [src]!</span>")
		return
	if (istype(W, /obj/item/card/id) || (istype(W, /obj/item/device/pda2) && W:ID_card))
		if (status & (BROKEN|NOPOWER))
			boutput(user, "<span class='alert'>The local air monitor has no power!</span>")
			return
		if (src.allowed(usr))
//			locked = !locked
//			boutput(user, "You [ locked ? "lock" : "unlock"] the local air monitor.")
			boutput(user, "<span class='alert'>Error: No atmospheric pipe network detected.</span>") // <-- dumb workaround until atmos processing is better
			return
		else
			boutput(user, "<span class='alert'>Access denied.</span>")
			return
	return ..()

/obj/machinery/alarm/attack_hand(mob/user)
	if(status & (NOPOWER|BROKEN))
		return
	user.Browse(return_text(user),"window=atmos")
	src.add_dialog(user)
	onclose(user, "atmos")

/obj/machinery/alarm/proc/return_text(mob/user)
	if ( (BOUNDS_DIST(src, user) > 0 ))
		if (!issilicon(user))
			src.remove_dialog(user)
			user.Browse(null, "window=atmos")
		return


	var/output = "<B>[name] Interface: </B><BR><HR>"
	if (!istype(environment))
		output += "<FONT color = 'red'>ERROR: Unable to determine environmental status!</FONT><BR><BR>"
		safe = -1
	else
		var/environment_pressure = MIXTURE_PRESSURE(environment)
		var/total_moles = TOTAL_MOLES(environment)

		if((environment_pressure < ONE_ATMOSPHERE*0.8) || (environment_pressure > ONE_ATMOSPHERE*1.2))
			output += "<FONT color = 'red'>"
		else if((environment_pressure < ONE_ATMOSPHERE*0.9) || (environment_pressure > ONE_ATMOSPHERE*1.1))
			output += "<FONT color = 'orange'>"
		else
			output += "<FONT color = 'blue'>"
		output += "Pressure: [environment_pressure] kPa</FONT><BR>"

		if((environment.temperature < (T0C-10)) || (environment.temperature > (T0C+50)))
			output += "<FONT color = 'red'>"
		else if((environment.temperature < (T0C)) || (environment.temperature > (T0C+40)))
			output += "<FONT color = 'orange'>"
		else
			output += "<FONT color = 'blue'>"
		output += "Temperature: [environment.temperature] K</FONT><BR><BR>"

		output += "<B>Composition:</B><BR>"

		if(environment.nitrogen < MOLES_N2STANDARD*0.8)
			output += "<FONT color = 'red'>"
		else if((environment.nitrogen < MOLES_N2STANDARD*0.9) || (environment.nitrogen > MOLES_N2STANDARD*1.1))
			output += "<FONT color = 'orange'>"
		else
			output += "<FONT color = 'blue'>"
		if(total_moles > 0)
			output += "N2: [round(100*environment.nitrogen/total_moles,0.01)]%</FONT><BR>"
		else
			output += "N2: N/A</FONT><BR>"

		if(environment.oxygen < MOLES_O2STANDARD*0.8)
			output += "<FONT color = 'red'>"
		else if((environment.oxygen < MOLES_O2STANDARD*0.9) || (environment.oxygen > MOLES_O2STANDARD*1.1))
			output += "<FONT color = 'orange'>"
		else
			output += "<FONT color = 'blue'>"
		if(total_moles > 0)
			output += "O2: [round(100*environment.oxygen/total_moles,0.01)]%</FONT><BR>"
		else
			output += "O2: N/A</FONT><BR>"

		if(environment.carbon_dioxide > 0.1)
			output += "<FONT color = 'red'>"
		else if(environment.carbon_dioxide > 0.05)
			output += "<FONT color = 'orange'>"
		else
			output += "<FONT color = 'blue'>"
		if(total_moles > 0)
			output += "CO2: [round(100*environment.carbon_dioxide/total_moles,0.01)]%</FONT><BR>"
		else
			output += "CO2: N/A</FONT><BR><BR>"

		if(environment.toxins > 2)
			output += "<FONT color = 'red'>WARNING: Toxins detected in environment!<BR>"
			if(total_moles > 0)
				output += "TOX: [round(100*environment.toxins/total_moles,0.01)]%</FONT><BR>"
			else
				output += "TOX: N/A</FONT><BR>"
		else if(environment.toxins > 1)
			output += "<FONT color = 'orange'>WARNING: Toxins detected in environment!<BR>"
			if(total_moles > 0)
				output += "TX: [round(100*environment.toxins/total_moles,0.01)]%</FONT><BR>"
			else
				output += "TX: N/A</FONT><BR>"
		else
			output += ""

		// Newly added gases should be added here manually since there's no nice way of using APPLY_TO_GASES here

		var/tgmoles = 0
		if(length(environment.trace_gases))
			for(var/datum/gas/trace_gas as anything in environment.trace_gases)
				tgmoles += trace_gas.moles

		if(tgmoles > 1)
			output += "<FONT color = 'red'>WARNING: unidentified gases present in environment!</FONT><BR>"

		if(e_gas)
			output += "<FONT color = 'red'>WARNING: Local override engaged, air supply is limited!</FONT><BR>"
	/*
	if(panic_mode > 0)
		var/seconds = panic_mode % 60
		var/minutes = (panic_mode - seconds)/60
		output += "<FONT color = 'red'>WARNING: Scrubbers on panic siphon for next [minutes]:[seconds]!</FONT><BR>"
	*/
	output += "<BR>"

	output += "Environment Status: "

	switch(safe)
		if(-1)
			output += "<FONT color = 'maroon'>UNKNOWN</FONT>"
		if(0)
			output += "<FONT color = 'red'>LETHAL</FONT>"
		if(1)
			output += "<FONT color = 'orange'>CAUTION</FONT>"
		else
			output += "<FONT color = 'blue'>OPTIMAL</FONT>"

	output += "<BR><HR>"

	/*output += "<TT>"
	if(locked && (!issilicon(user)))
		output += "<I><FONT color = 'gray'>No atmospheric pipe network detected.<BR>Control functions unavailable.</FONT></I>"
	else
		if(!issilicon(user))
			output += "<I>Swipe card to lock interface.</I><BR><BR>"
		output += "<A href='?src=\ref[src];toggle_override=1'>Toggle Local Override</A><BR>"
		if(panic_mode > 0)
			output += "<A href='?src=\ref[src];unpanic=1'>Cancel Panic Siphon</A><BR>"
		else
			output += "<A href='?src=\ref[src];panic=1'>Engage Two-Minute Panic Siphon</A> - <FONT color = 'red'>WARNING: Pressure may temporarily drop below safe levels!</FONT><BR>"
		output += "</TT>" */
	return output

/obj/machinery/alarm/Topic(href, href_list)
	if(..())
		return
	/*
	if(href_list["toggle_override"])
		var/datum/radio_frequency/frequency = radio_controller.return_frequency(control_frequency)

		if(!frequency) return

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = 1
		signal.data["tag"] = id
		if(!e_gas)
			signal.data["command"] = "valve_divert"
		else
			signal.data["command"] = "valve_undivert"

		frequency.post_signal(src, signal)

		e_gas = !e_gas

	if(href_list["panic"])
		panic(120)

	if(href_list["unpanic"])
		unpanic()  */

	src.add_fingerprint(usr)

/obj/machinery/alarm/power_change()
	if(powered(ENVIRON))
		status &= ~NOPOWER
	else
		status |= NOPOWER
/*
/obj/machinery/alarm/proc/panic(var/time)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(control_frequency)

	if(!frequency) return

	panic_mode = time

	var/datum/signal/signal = get_free_signal()
	signal.source = src
	signal.transmission_method = 1
	signal.data["tag"] = id
	signal.data["command"] = "set_siphon"

	frequency.post_signal(src, signal)

	signal = get_free_signal()
	signal.source = src
	signal.transmission_method = 1
	signal.data["tag"] = id
	signal.data["command"] = "purge"

	frequency.post_signal(src, signal)

/obj/machinery/alarm/proc/unpanic()
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(control_frequency)

	if(!frequency) return

	panic_mode = 0

	var/datum/signal/signal = get_free_signal()
	signal.source = src
	signal.transmission_method = 1
	signal.data["tag"] = id
	signal.data["command"] = "set_scrubbing"

	frequency.post_signal(src, signal)

	signal = get_free_signal()
	signal.source = src
	signal.transmission_method = 1
	signal.data["tag"] = id
	signal.data["command"] = "end_purge"

	frequency.post_signal(src, signal) */
