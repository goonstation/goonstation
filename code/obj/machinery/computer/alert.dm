var/global/obj/minimap/alert/alertmap

/// Zone alert status
/datum/zone_alert
	var/zone = null //!Area Name
	var/atmos = ALERT_SEVERITY_RESET //!Atmospheric Alert Severity
	var/fire = ALERT_SEVERITY_RESET	//!Fire Alert Severity
	var/power = ALERT_SEVERITY_RESET //!Power Alert Severity

	proc/set_severity(kind, severity)
		switch(kind)
			if(ALERT_KIND_ATMOS)
				src.atmos = severity
			if(ALERT_KIND_FIRE)
				src.fire = severity
			if(ALERT_KIND_POWER)
				src.power = severity

	proc/highest_severity()
		return max(src.atmos, src.power, src.fire)

/obj/machinery/computer/general_alert
	name = "general alert computer"
	icon_state = "alert:0"
	circuit_type = /obj/item/circuitboard/general_alert
	base_icon_state = "alert"
	var/list/datum/zone_alert/alerts = list()
	var/obj/minimap_controller/alertmap_controller
	var/atom/movable/minimap_ui_handler/minimap_controller/alert_minimap_ui

	var/receive_frequency = FREQ_ALARM
	var/respond_frequency = FREQ_PDA

/obj/machinery/computer/general_alert/New()
	..()
	src.connect_to_minimap()

	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, "control", frequency)
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, "respond", respond_frequency)
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, "receive", receive_frequency)

/obj/machinery/computer/general_alert/proc/connect_to_minimap()
	if (!global.alertmap)
		global.alertmap = new
	if (!src.alertmap_controller)
		src.alertmap_controller = new(global.alertmap)
	if (!src.alert_minimap_ui)
		src.alert_minimap_ui = new(src, "alert_map", src.alertmap_controller, "Alert Map", "ntos")

/obj/machinery/computer/general_alert/initialize()
	. = ..()
	global.alertmap.initialise_minimap()

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
			if(severity == ALERT_SEVERITY_RESET && alert.highest_severity() == ALERT_SEVERITY_RESET)
				src.alerts -= alert
				qdel(alert)
			return

	// no matching zone in the list, so add it
	var/datum/zone_alert/new_zone = new /datum/zone_alert
	new_zone.zone = zone
	new_zone.set_severity(kind, severity)
	src.alerts += new_zone
	src.update_alert_icon()

/obj/machinery/computer/general_alert/attack_hand(mob/user)
	if(..())
		return

	if(!src.alertmap_controller || !src.alert_minimap_ui)
		src.connect_to_minimap()

	src.alert_minimap_ui.ui_interact(user)


/obj/machinery/computer/general_alert/disposing()
	. = ..()
	qdel(src.alertmap_controller)
	src.alertmap_controller = null
	qdel(src.alert_minimap_ui)
	src.alert_minimap_ui = null

///Check the current maximum alert level
/obj/machinery/computer/general_alert/proc/check_alert_level()
	var/current_alert_level = ALERT_SEVERITY_RESET
	for (var/datum/zone_alert/alert in src.alerts)
		current_alert_level = max(current_alert_level, alert.highest_severity())
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
