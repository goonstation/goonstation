//
// Alarm
//

#define ALARM_SEVERE 0
#define ALARM_MINOR 1
#define ALARM_GOOD 2
#define ALARM_BROKEN 3
#define ALARM_NOPOWER 4

/obj/machinery/alarm
	name = "air monitor"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm"
	power_usage = 5
	power_channel = ENVIRON
	anchored = ANCHORED
	plane = PLANE_NOSHADOW_ABOVE
	/// save some CPU by only checking every tick when something is amiss
	var/skipprocess = 0
	var/alarm_frequency = FREQ_ALARM
	var/alarm_zone = null
	var/control_frequency = FREQ_AIR_ALARM_CONTROL
	/// keeps track of last alarm status
	var/last_safe = ALARM_NOPOWER
	var/datum/gas_mixture/environment
	var/alertingAI = FALSE // Does this alarm currently have an AI alarm active

	/// this is a list of safe & good partial pressures of each gas. If all gasses are in the good range, the alarm will show green. If any gas is outside the safe range, the alarm will show alert. Otherwise caution.
	/// most of these values are taken from lung.dm
	var/static/list/gas_safety_levels = list(
		list(varname = "oxygen", friend_name = "O2", safe_min=16, safe_max=INFINITY, good_min=20, good_max=INFINITY),
		list(varname = "nitrogen", friend_name = "N2", safe_min=0, safe_max=INFINITY, good_min=60, good_max=INFINITY),
		list(varname = "carbon_dioxide", friend_name = "CO2", safe_min=0, safe_max=9, good_min=0, good_max=2),
		list(varname = "toxins", friend_name = "Plasma", safe_min=0, safe_max=8, good_min=0, good_max=0.4), //you start taking damage a 0.4, but it caps out at 8kpa
		list(varname = "farts", friend_name = "Farts", safe_min=0, safe_max=16.9, good_min=0, good_max=6.9),
		list(varname = "radgas", friend_name = "Fallout", safe_min=0, safe_max=6, good_min=0, good_max=0.1), //any fallout is bad, but it caps out ~6kpa
		list(varname = "nitrous_oxide", friend_name = "N2O", safe_min=0, safe_max=INFINITY, good_min=0, good_max=0.1),
	//	list(varname = "oxygen_agent_b", friend_name = "Unknown", safe_min=0, safe_max=INFINITY, good_min=0, good_max=INFINITY),
	)
	var/const/temp_safe_min = T0C-15
	var/const/temp_safe_max = DEFAULT_LUNG_AIR_TEMP_TOLERANCE_MAX
	var/const/temp_good_min = T0C
	var/const/temp_good_max = T20C+20

/obj/machinery/alarm/New()
	..()
	MAKE_SENDER_RADIO_PACKET_COMPONENT(null, "alarm", alarm_frequency)
	MAKE_SENDER_RADIO_PACKET_COMPONENT(null, "control", control_frequency) // seems to be unused?

	if(!alarm_zone)
		var/area/A = get_area(loc)
		if(A.name)
			alarm_zone = A.name
		else
			alarm_zone = "Unregistered"

/obj/machinery/alarm/get_desc(dist, mob/user)
	. = ..()
	if(status & (NOPOWER | BROKEN))
		. += "It doesn't seem to be working."
		return

	switch(last_safe)
		if(ALARM_SEVERE)
			. += "It is showing an alert status. Maybe you should hold your breath."
		if(ALARM_MINOR)
			. += "It is showing a caution alarm. Something isn't right, but you can still breathe."
		if(ALARM_GOOD)
			. += "It is showing optimal status. Take a deep breath of fresh-ish air!"

/obj/machinery/alarm/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirAlarm", src.name)
		ui.open()

/obj/machinery/alarm/ui_static_data(mob/user)
		return list("boundaries" = gas_safety_levels)

/obj/machinery/alarm/ui_data(mob/user)
	. = list("gasses" = list())
	var/env_moles = environment ? TOTAL_MOLES(environment) : 0
	if(env_moles == 0)
		env_moles = ATMOS_EPSILON
		for(var/list/entry as anything in gas_safety_levels)
			.["gasses"][entry["varname"]] = 0
	else
		var/env_pressure = (env_moles*R_IDEAL_GAS_EQUATION*environment.temperature)/environment.volume
		for(var/list/entry as anything in gas_safety_levels)
			.["gasses"][entry["varname"]] = (environment.vars[entry["varname"]]/env_moles)*env_pressure
	.["temperature"] = environment?.temperature
	.["safe"] = last_safe


/obj/machinery/alarm/process()
	.=..()

	var/safe = ALARM_GOOD

	if(status & NOPOWER)
		if (src.last_safe != ALARM_NOPOWER)
			src.UpdateOverlays(null, "light")
			src.last_safe = ALARM_NOPOWER
		return
	if(status & BROKEN)
		src.icon_state = "alarm_broken"
		if (src.last_safe != ALARM_BROKEN)
			src.UpdateOverlays(null, "light")
			src.last_safe = ALARM_BROKEN
		return

	if (src.skipprocess)
		src.skipprocess--
		return

	var/turf/location = src.loc
	if (!( istype(location, /turf) ))
		return

	environment = location.return_air()
	environment.check_if_dangerous()
	if (!istype(environment))
		safe = ALARM_SEVERE
	else
		var/env_moles = TOTAL_MOLES(environment)
		if(env_moles == 0)
			safe = ALARM_SEVERE //it's a vacuum, you can't breathe that
		else if (environment.temperature > temp_safe_max || environment.temperature < temp_safe_min)
			safe = ALARM_SEVERE //dangerously hot or cold
		else
			if (environment.temperature > temp_good_max || environment.temperature < temp_good_min)
				safe = ALARM_MINOR //uncomfortably hot or cold
			var/env_pressure = (env_moles*R_IDEAL_GAS_EQUATION*environment.temperature)/environment.volume
			for(var/list/entry as anything in gas_safety_levels)
				var/partial_pressure = (environment.vars[entry["varname"]]/env_moles)*env_pressure
				if(partial_pressure > entry["safe_max"] || partial_pressure < entry["safe_min"])
					safe = ALARM_SEVERE
					break //no point doing further checks
				if(partial_pressure > entry["good_max"] || partial_pressure < entry["good_min"])
					safe = ALARM_MINOR

	if(safe == ALARM_GOOD)
		src.skipprocess = 2

	if (src.last_safe == safe) //no change, no icon update/alert
		return

	var/overlay_icon_state = null
	switch(safe)
		if(ALARM_SEVERE)
			overlay_icon_state = "alarm_alert"
		if(ALARM_MINOR)
			overlay_icon_state = "alarm_safe"
		if(ALARM_GOOD)
			overlay_icon_state = "alarm_good"

	var/mutable_appearance/light_ov = mutable_appearance(src.icon, overlay_icon_state)
	light_ov.plane = PLANE_SELFILLUM
	src.UpdateOverlays(light_ov, "light")

	if (safe == ALARM_GOOD)
		if (src.alertingAI)
			for_by_tcl(aiPlayer, /mob/living/silicon/ai)
				aiPlayer.cancelAlarm("Atmosphere", get_area(src), src)
			src.alertingAI = FALSE
	else
		var/list/cameras = list()
		for_by_tcl(C, /obj/machinery/camera)
			if(get_area(C) == get_area(src))
				cameras += C
		for_by_tcl(aiPlayer, /mob/living/silicon/ai)
			aiPlayer.triggerAlarm("Atmosphere", get_area(src), cameras, src)
		src.alertingAI = TRUE

	if(alarm_frequency)
		post_alert(safe)
		last_safe = safe


/obj/machinery/alarm/proc/post_alert(alert_level)
	var/datum/signal/alert_signal = get_free_signal()
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = alarm_zone
	alert_signal.data["type"] = "Atmospheric"

	switch (alert_level)
		if (ALARM_SEVERE)
			alert_signal.data["alert"] = "severe"
		if (ALARM_MINOR)
			alert_signal.data["alert"] = "minor"
		if (ALARM_GOOD)
			alert_signal.data["alert"] = "reset"

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, alert_signal, null, "alarm")

/obj/machinery/alarm/attackby(var/obj/item/W, user)
	if (issnippingtool(W))
		status ^= BROKEN
		src.add_fingerprint(user)
		src.visible_message(SPAN_ALERT("[user] has [(status & BROKEN) ? "de" : "re"]activated [src]!"))
		src.process()
		return
	return ..()

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

#undef ALARM_GOOD
#undef ALARM_MINOR
#undef ALARM_SEVERE
