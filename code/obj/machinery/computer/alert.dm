/// Zone alert status
/datum/zone_alert
	var/zone = null //!Area Name
	var/atmos = ALERT_SEVERITY_RESET //!Atmospheric Alert Severity
	var/fire = ALERT_SEVERITY_RESET	//!Fire Alert Severity
	var/power = ALERT_SEVERITY_RESET //!Power Alert Severity
	var/motion = ALERT_SEVERITY_RESET //!Motion Alert Severity

	proc/set_severity(kind, severity)
		switch(kind)
			if(ALERT_KIND_ATMOS)
				src.atmos = severity
			if(ALERT_KIND_FIRE)
				src.fire = severity
			if(ALERT_KIND_POWER)
				src.power = severity
			if(ALERT_KIND_MOTION)
				src.motion = severity

	proc/highest_severity()
		return max(src.atmos, src.power, src.fire, src.motion)

/obj/machinery/computer/general_alert
	name = "engineering alert computer"
	icon_state = "alert:0"
	circuit_type = /obj/item/circuitboard/general_alert
	base_icon_state = "alert"
	var/list/datum/zone_alert/alerts = list()

	var/receive_frequency = FREQ_ALARM
	var/respond_frequency = FREQ_PDA

/obj/machinery/computer/general_alert/New()
	..()
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, "control", frequency)
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, "respond", respond_frequency)
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, "receive", receive_frequency)

/obj/machinery/computer/general_alert/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	//Oh, someone is asking us for data instead of reporting a thing.
	if((signal.data["command"] == "report_alerts") && signal.data["sender"])
		src.generate_signal_report(signal)
		return

	if(signal.data["command"] != "update_alert")
		return

	var/zone = signal.data["zone"]
	var/severity = signal.data["alert"]
	var/kind = signal.data["type"]

	if(!zone || !severity || !kind) return

	src.update_alert(zone, kind, severity)

///Generate the report used for the EngieAlerter PDA app
/obj/machinery/computer/general_alert/proc/generate_signal_report(datum/signal/signal)
	var/datum/signal/newsignal = get_free_signal()
	newsignal.data["address_1"] = signal.data["sender"]
	newsignal.data["command"] = "reply_alerts"
	var/list/priority = list()
	var/list/minor = list()
	for(var/datum/zone_alert/alert in src.alerts)
		switch(alert.highest_severity())
			if(ALERT_SEVERITY_PRIORITY)
				priority += alert.zone
			if(ALERT_SEVERITY_MINOR)
				minor += alert.zone

	if (length(priority))
		newsignal.data["severe_list"] = jointext(priority, ";")
	if (length(minor))
		newsignal.data["minor_list"] = jointext(minor, ";")
	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal, null, "respond")

///Update the alert severity of a given zone and kind
/obj/machinery/computer/general_alert/proc/update_alert(zone, kind, severity)
	for(var/datum/zone_alert/alert in src.alerts)
		if (alert.zone == zone)
			alert.set_severity(kind, severity)
			src.update_alert_icon()
			return

	// no matching zone in the list, so add it
	var/datum/zone_alert/new_zone = new /datum/zone_alert
	new_zone.zone = zone
	new_zone.set_severity(kind, severity)
	src.alerts += new_zone
	src.update_alert_icon()

/obj/machinery/computer/general_alert/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.) return

	var/removing_zone = params["area_ckey"]
	for (var/datum/zone_alert/alert in src.alerts)
		if(ckey(alert.zone) == removing_zone)
			switch(action)
				if("clear_atmos")
					alert.set_severity(ALERT_KIND_ATMOS, ALERT_SEVERITY_RESET)
					break
				if("clear_fire")
					alert.set_severity(ALERT_KIND_FIRE, ALERT_SEVERITY_RESET)
					break
				if("clear_power")
					alert.set_severity(ALERT_KIND_POWER, ALERT_SEVERITY_RESET)
					break
				if("clear_motion")
					alert.set_severity(ALERT_KIND_MOTION, ALERT_SEVERITY_RESET)
					break
	src.update_alert_icon()

/obj/machinery/computer/general_alert/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AlertComputer")
		ui.open()

/obj/machinery/computer/general_alert/ui_data(mob/user)
	. = ..()
	.["alerts"] = list()
	for (var/datum/zone_alert/alert in src.alerts)
		.["alerts"] += list(list(
			"area_ckey" = ckey(alert.zone),
			"zone" = alert.zone,
			"atmos" = alert.atmos,
			"fire" = alert.fire,
			"power" = alert.power,
			"motion" = alert.motion
		))

/obj/machinery/computer/general_alert/attack_hand(mob/user)
	if(..())
		return
	src.ui_interact(user)

///Check the current maximum alert level
/obj/machinery/computer/general_alert/proc/check_alert_level()
	var/current_alert_level = ALERT_SEVERITY_RESET
	for (var/datum/zone_alert/alert in src.alerts)
		var/new_severity = alert.highest_severity()
		if (new_severity > current_alert_level)
			current_alert_level = new_severity
	return current_alert_level

///Update the icon state based on alert level
/obj/machinery/computer/general_alert/proc/update_alert_icon()
	if(src.status & BROKEN)
		icon_state = "alertb"
		return
	if(src.status & NOPOWER)
		icon_state = "alert0"
		return
	switch(src.check_alert_level())
		if(ALERT_SEVERITY_PRIORITY)
			icon_state = "alert:2"
		if(ALERT_SEVERITY_MINOR)
			icon_state = "alert:1"
		if(ALERT_SEVERITY_RESET)
			icon_state = "alert:0"

/obj/machinery/computer/general_alert/power_change()
	. = ..()
	src.update_alert_icon()
