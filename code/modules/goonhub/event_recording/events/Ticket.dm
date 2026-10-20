
/// Record a new ticket
/datum/eventRecord/Ticket
	eventType = "ticket"
	body = /datum/eventRecordBody/TracksPlayer/Ticket

	send(
		player_id,
		target,
		reason,
		issuer,
		issuer_job,
		issuer_ckey
	)
		. = ..(args)
