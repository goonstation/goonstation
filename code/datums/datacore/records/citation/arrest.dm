/datum/db_record/citation/arrest

/datum/db_record/citation/arrest/build_fields()
	return alist(
		"id" 			= new /datum/record_field/string(src, "ID", "000000", @"[a-f0-9]{6}"),
		"time"			= new /datum/record_field/string(src, "Time Issued", "2053-01-01T00:00:00Z"),
		"time_closed"	= new /datum/record_field/string(src, "Time Closed", "N/A"),
		"authority"		= new /datum/record_field/string(src, "Authority", "Nanotrasen Corporate Security"),
		"type"			= new /datum/record_field/choice(src, "Type", "ARREST", list("ARREST")),
		"target"		= new /datum/record_field/string(src, "Suspect", "Unknown"),
		"status"		= new /datum/record_field/choice(src, "Status", "OPEN", list("OPEN", "CLOSED")),
		"issuer"		= new /datum/record_field/string(src, "Issuer", "Unknown"),
		"issuer_job"	= new /datum/record_field/string(src, "Issuer Job", "Unknown"),
		"reason"		= new /datum/record_field/string(src, "Reason", "Unknown"),
		"closer"		= new /datum/record_field/string(src, "Closer", "N/A"),
		"closer_job"	= new /datum/record_field/string(src, "Closer Job", "N/A"),
		"resolution"	= new /datum/record_field/string(src, "Resolution", "N/A"),
	)

/datum/db_record/citation/arrest/New(target, issuer, issuer_job, reason)
	. = ..()

	src["time"] = global.toIso8601InCharacter(world.timeofday)
	src["target"] = target
	src["issuer"] = issuer
	src["issuer_job"] = issuer_job
	src["reason"] = reason

	var/datum/db_record/personnel/security/record = global.data_core.security.find_record("name", target)
	if (record)
		record["criminal"] = SECURITY::ARREST::STATE::ARREST
		record["sec_flag"] = reason

	logTheThing(LOG_ADMIN, usr, "issues an arrest warrant using [issuer] ([issuer_job])'s ID. It is a warrant for <b>[target]</b> with the reason: [reason].")

	var/turf/T = null
	for_by_tcl(H, /mob/living/carbon/human)
		if (H.real_name == target)
			T = get_turf(H)
			break

	var/where_text = T ? global.showCoords(T.x, T.y, T.z, ghostjump = TRUE) : "?,?,?"
	var/ghost_message = "An arrest warrant for crew member \"[target]\" ([where_text]) has been issued by [issuer], with reason: \"[reason]\""
	global.message_ghosts(ghost_message)

	var/datum/signal/signal = global.get_free_signal()
	signal.data["command"] = "text_message"
	signal.data["sender_name"] = "SEC-MAILBOT"
	signal.data["sender"] = "00000000"
	signal.data["group"] = list(MGD_SECURITY, MGA_ARREST)
	signal.data["message"] = "An arrest warrant for crew member \"[target]\" has been issued by [issuer], with reason: \"[reason]\""
	global.radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

/datum/db_record/citation/arrest/to_list_display_string()
	return copytext(src["time"], -9, -1) + "  ARREST  " + global.pad_trailing(src["status"], 9) + src["target"]

/datum/db_record/citation/arrest/proc/close(closer, closer_job, resolution)
	if (src["status"] == "CLOSED")
		CRASH("Attempted to close an arrest warrant that is already closed.")

	src["status"] = "CLOSED"
	src["time_closed"] = global.toIso8601InCharacter(world.timeofday)
	src["closer"] = closer
	src["closer_job"] = closer_job
	src["resolution"] = resolution

	var/target = src["target"]
	var/datum/db_record/personnel/security/record = global.data_core.security.find_record("name", target)
	if (record)
		var/list/datum/db_record/citation/arrest/arrests = global.data_core.get_open_arrests(target)
		if (length(arrests))
			record["sec_flag"] = arrests[1]["reason"]
		else
			record["criminal"] = SECURITY::ARREST::STATE::NONE
			record["sec_flag"] = "None"

	logTheThing(LOG_ADMIN, usr, "closes an arrest warrant using [closer] ([closer_job])'s ID. It was a warrant for <b>[target]</b> with the resolution: [resolution].")

	var/turf/T = null
	for_by_tcl(H, /mob/living/carbon/human)
		if (H.real_name == target)
			T = get_turf(H)
			break

	var/where_text = T ? global.showCoords(T.x, T.y, T.z, ghostjump = TRUE) : "?,?,?"
	var/ghost_message = "An arrest warrant for crew member \"[target]\" ([where_text]) has been closed by [closer], with resolution: \"[resolution]\""
	global.message_ghosts(ghost_message)

	var/datum/signal/signal = global.get_free_signal()
	signal.data["command"] = "text_message"
	signal.data["sender_name"] = "SEC-MAILBOT"
	signal.data["sender"] = "00000000"
	signal.data["group"] = list(MGD_SECURITY, MGA_ARREST)
	signal.data["message"] = "An arrest warrant for crew member \"[target]\" has been closed by [closer], with resolution: \"[resolution]\""
	global.radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

/datum/db_record/citation/arrest/get_name()
	return "Arrest Warrant - [src["target"]]"

/datum/db_record/citation/arrest/get_date()
	var/status = src["status"]
	var/time = src["time"]
	var/display_time = copytext(time, 1, 11) + " " + copytext(time, 12, 20)

	if (status == "OPEN")
		return {"\
			<table width="365px">\
			<tr><td width="200px">DATE OF ISSUE</td><td>[display_time]</td></tr>\
			<tr><td width="200px">STATUS</td><td>[status]</td></tr>\
			</table>\
		"}
	else
		var/time_closed = src["time_closed"]
		var/display_time_closed = copytext(time_closed, 1, 11) + " " + copytext(time_closed, 12, 20)

		return {"\
			<table width="365px">\
			<tr><td width="200px">DATE OF ISSUE</td><td>[display_time]</td></tr>\
			<tr><td width="200px">DATE OF CLOSURE</td><td>[display_time_closed]</td></tr>\
			<tr><td width="200px">STATUS</td><td>[status]</td></tr>\
			</table>\
		"}

/datum/db_record/citation/arrest/get_recipient()
	return {"\
		<table width="365px">\
		<tr><td width="200px">SUSPECT</td><td>[src["target"]]</td></tr>\
		</table>\
	"}

/datum/db_record/citation/arrest/get_reason()
	return {"\
		<table width="365px">\
		<tr><td width="200px">ISSUED BY</td><td>[src["issuer"]]</td></tr>\
		<tr><td width="200px">ASSIGNMENT</td><td>[src["issuer_job"]]</td></tr>\
		</table>\
		<table width="365px">\
		<tr><td width="100px">REASON</td><td>[src["reason"]]</td></tr>\
		</table>\
	"}

/datum/db_record/citation/arrest/get_resolution()
	if (src["status"] == "OPEN")
		return

	return {"\
		<table width="365px">\
		<tr><td width="200px">CLOSED BY</td><td>[src["closer"]]</td></tr>\
		<tr><td width="200px">ASSIGNMENT</td><td>[src["closer_job"]]</td></tr>\
		</table>\
		<table width="365px">\
		<tr><td width="100px">RESOLUTION</td><td>[src["resolution"]]</td></tr>\
		</table>\
	"}
