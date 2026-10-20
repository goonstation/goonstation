/datum/db_record/citation/ticket
	fields = alist(
		"id" 			= new /datum/record_field/string("ID", "000000", @"[a-f0-9]{6}"),
		"time"			= new /datum/record_field/string("Time Issued", "2053-01-01T00:00:00Z"),
		"authority"		= new /datum/record_field/string("Authority", "Nanotrasen Corporate Security"),
		"type"			= new /datum/record_field/choice("Type", "TICKET", list("TICKET", "FINE")),
		"target"		= new /datum/record_field/string("Recipient", "Unknown"),
		"issuer"		= new /datum/record_field/string("Issuer", "Unknown"),
		"issuer_job"	= new /datum/record_field/string("Issuer Job", "Unknown"),
		"reason"		= new /datum/record_field/string("Reason", "Unknown"),
	)

/datum/db_record/citation/ticket/New(authority, target, issuer, issuer_job, reason)
	. = ..()

	src["time"] = global.toIso8601InCharacter(world.timeofday)
	src["authority"] = authority
	src["target"] = target
	src["issuer"] = issuer
	src["issuer_job"] = issuer_job
	src["reason"] = reason

	logTheThing(LOG_ADMIN, usr, "issues a ticket using [issuer] ([issuer_job])'s ID. It is a ticket on <b>[target]</b> with the reason: [reason].")

	var/mob/living/M = usr
	var/datum/eventRecord/Ticket/event = new()
	event.send(
		M.mind.get_player().id,
		target,
		html_decode(reason),
		M.real_name,
		M.job,
		M.ckey,
	)

/datum/db_record/citation/ticket/to_list_display_string()
	return copytext(src["time"], 12, 20) + "  TICKET  " + "         " + src["target"]

/datum/db_record/citation/ticket/get_name()
	return "Official Caution - [src["target"]]"
