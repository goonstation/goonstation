/// Alert Minimap
/obj/minimap/alert
	name = "Alert Map"
	map_path = /datum/minimap/area_map
	map_type = MAP_ALERTS

/// General Alert Computer
/obj/machinery/computer/general_alert
	name = "general alert computer"
	icon_state = "alert:0"
	circuit_type = /obj/item/circuitboard/general_alert
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	var/receive_frequency = FREQ_ALARM
	var/respond_frequency = FREQ_PDA
	var/obj/minimap_controller/alertmap_controller
	var/atom/movable/minimap_ui_handler/minimap_controller/general_alert/alert_minimap_ui
	machine_registry_idx = MACHINES_GENERAL_ALERT

/obj/machinery/computer/general_alert/New()
	src.connect_to_minimap()
	..()
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, "control", frequency)
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, "respond", respond_frequency)
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, "receive", receive_frequency)

/obj/machinery/computer/general_alert/proc/connect_to_minimap()
	var/obj/minimap/alert/alert_map = get_singleton(/obj/minimap/alert)
	if (!src.alertmap_controller)
		src.alertmap_controller = new(alert_map)
	if (!src.alert_minimap_ui)
		src.alert_minimap_ui = new(src, "alert_map", src.alertmap_controller, "Alert Map", "nanotrasen")

/obj/machinery/computer/general_alert/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	//Oh, someone is asking us for data instead of reporting a thing.
	if((signal.data["command"] == "report_alerts") && signal.data["sender"])
		var/datum/signal/newsignal = get_free_signal()

		newsignal.data["address_1"] = signal.data["sender"]
		newsignal.data["command"] = "reply_alerts"
		if(priority_alarms.len)
			newsignal.data["severe_list"] = jointext(priority_alarms, ";")
		if(minor_alarms.len)
			newsignal.data["minor_list"] = jointext(minor_alarms, ";")

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal, null, "respond")
		return


	var/zone = signal.data["zone"]
	var/severity = signal.data["alert"]

	if(!zone || !severity) return

	priority_alarms -= zone
	minor_alarms -= zone

	if (severity == "severe")
		priority_alarms += zone
	else if (severity == "minor")
		minor_alarms += zone


/obj/machinery/computer/general_alert/attack_hand(mob/user)
	if(..())
		return

	if (!src.alertmap_controller || !src.alert_minimap_ui)
		src.connect_to_minimap()

	src.alert_minimap_ui.ui_interact(user)

/obj/machinery/computer/general_alert/disposing()
	. = ..()
	qdel(src.alertmap_controller)
	src.alertmap_controller = null
	qdel(src.alert_minimap_ui)
	src.alert_minimap_ui = null


/obj/machinery/computer/general_alert/process()
	if(priority_alarms.len)
		icon_state = "alert:2"

	else if(minor_alarms.len)
		icon_state = "alert:1"

	else
		icon_state = "alert:0"

	..()

	src.updateDialog()

/obj/machinery/computer/general_alert/proc/return_text()
	var/priority_text
	var/minor_text

	if(priority_alarms.len)
		for(var/zone in priority_alarms)
			priority_text += "<FONT color='red'><B>[zone]</B></FONT>  <A href='byond://?src=\ref[src];priority_clear=[ckey(zone)]'>X</A><BR>"
	else
		priority_text = "No priority alerts detected.<BR>"

	if(minor_alarms.len)
		for(var/zone in minor_alarms)
			minor_text += "<B>[zone]</B>  <A href='byond://?src=\ref[src];minor_clear=[ckey(zone)]'>X</A><BR>"
	else
		minor_text = "No minor alerts detected.<BR>"

	var/output = {"<B>[name]</B><HR>
<B>Priority Alerts:</B><BR>
[priority_text]
<BR>
<HR>
<B>Minor Alerts:</B><BR>
[minor_text]
<BR>"}

	return output

/obj/machinery/computer/general_alert/Topic(href, href_list)
	if(..())
		return

	if(href_list["priority_clear"])
		var/removing_zone = href_list["priority_clear"]
		for(var/zone in priority_alarms)
			if(ckey(zone) == removing_zone)
				priority_alarms -= zone

	if(href_list["minor_clear"])
		var/removing_zone = href_list["minor_clear"]
		for(var/zone in minor_alarms)
			if(ckey(zone) == removing_zone)
				minor_alarms -= zone
