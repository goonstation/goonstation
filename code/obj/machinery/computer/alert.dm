///Station system alert data
/datum/alert
	///Area name
	var/zone = null
	/// Alert Kind i.e. atmos/fire/power
	var/kind = null
	///How bad is it
	var/severity = null

/obj/machinery/computer/general_alert
	name = "engineering alert computer"
	icon_state = "alert:0"
	circuit_type = /obj/item/circuitboard/general_alert
	base_icon_state = "alert"
	var/list/datum/alert/alerts = list()

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

	var/datum/alert/new_alert = new /datum/alert
	new_alert.zone = zone
	new_alert.severity = severity
	new_alert.kind = kind

	src.update_alerts(new_alert)

///Generate the report used for the EngieAlerter PDA app
/obj/machinery/computer/general_alert/proc/generate_signal_report(datum/signal/signal)
	var/datum/signal/newsignal = get_free_signal()
	newsignal.data["address_1"] = signal.data["sender"]
	newsignal.data["command"] = "reply_alerts"
	var/list/priority = list()
	var/list/minor = list()
	for (var/datum/alert/alert in src.alerts)
		switch(alert.severity)
			if(ALERT_SEVERITY_PRIORITY)
				priority += alert.zone
			if(ALERT_SEVERITY_MINOR)
				minor += alert.zone
	if (length(priority))
		newsignal.data["severe_list"] = jointext(priority, ";")
	if (length(minor))
		newsignal.data["minor_list"] = jointext(minor, ";")
	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal, null, "respond")

///Update the ale
/obj/machinery/computer/general_alert/proc/update_alerts(datum/alert/alert_update)
	for (var/datum/alert/existing_alert in src.alerts)
		if (existing_alert.zone == alert_update.zone)
			if(existing_alert.kind == alert_update.kind)
				src.alerts -= existing_alert
				break
	if(alert_update.severity == ALERT_SEVERITY_RESET)
		return
	src.alerts += alert_update
	src.update_alert_icon()

/obj/machinery/computer/general_alert/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.) return

	var/removing_zone = params["area_ckey"]
	for (var/datum/alert/alert in src.alerts)
		if(ckey(alert.zone) == removing_zone)
			switch(action) {
				if("clear_atmos")
					if(alert.kind == ALERT_KIND_ATMOS)
						src.alerts -= alert
						break
				if("clear_fire")
					if(alert.kind == ALERT_KIND_FIRE)
						src.alerts -= alert
						break
				if("clear_power")
					if(alert.kind == ALERT_KIND_POWER)
						src.alerts -= alert
						break
			}
	src.update_alert_icon()

/obj/machinery/computer/general_alert/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AlertComputer")
		ui.open()

/obj/machinery/computer/general_alert/ui_data(mob/user)
	. = ..()
	.["alerts"] = list()
	for (var/datum/alert/alert in src.alerts)
		var/area_ckey = ckey(alert.zone)
		if(!(area_ckey in .["alerts"]))
			.["alerts"][area_ckey] = list()
		.["alerts"][area_ckey]["area_ckey"] = area_ckey
		.["alerts"][area_ckey]["area_name"] = alert.zone
		.["alerts"][area_ckey][alert.kind] = alert.severity

/obj/machinery/computer/general_alert/attack_hand(mob/user)
	if(..())
		return
	src.ui_interact(user)

///Check the current maximum alert level
/obj/machinery/computer/general_alert/proc/check_alert_level()
	var/current_alert_level = ALERT_SEVERITY_RESET
	for (var/datum/alert/alert in src.alerts)
		if (alert.severity == ALERT_SEVERITY_PRIORITY)
			current_alert_level = alert.severity
			break
		if (current_alert_level != ALERT_SEVERITY_MINOR && alert.severity == ALERT_SEVERITY_MINOR)
			current_alert_level = alert.severity
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
