/datum/random_event/minor/transmission
	name = "Emergency Transmission"
	disabled = 1 // set to 0 once someone actually tells me that this is fine to add, mostly from the lore standpoint
	weight = 10
	var/list/event_transmissions

	event_effect()
		..()
		if(!event_transmissions)
			var/fname = "strings/event_transmissions.json"
			if(fexists(fname))
				event_transmissions = json_decode(file2text(fname))
		if(!event_transmissions)
			logTheThing(LOG_DEBUG, src, "Event transmission JSON file loading failed.")
			return
		var/event = pick(event_transmissions)
		var/command_report = event["text"]
		if(event["x"])
			for_by_tcl(tele, /obj/machinery/networked/teleconsole)
				var/datum/teleporter_bookmark/bm = new
				bm.name = "<b>emergency transmission source</b>"
				bm.x = (event["x"] + XSUBTRACT) / XMULTIPLY
				bm.y = (event["y"] + YSUBTRACT) / YMULTIPLY
				bm.z = 2 + ZSUBTRACT // adventure z-level is default
				if(event["z"])
					bm.z = event["z"] + ZSUBTRACT
				tele.bookmarks.Add(bm)
				tele.updateUsrDialog()
			command_report += "\n\nTransmission source stored in the Teleportation Console."

		command_announcement(replacetext(command_report, "\n", "<br>"), "Emergency Broadcast Received", 'sound/misc/announcement_1.ogg', do_sanitize=0, alert_origin=ALERT_GENERAL);
		return

	is_event_available(var/ignore_time_lock = 0)
		return 0
