
/// Record a new ticket
/datum/eventRecord/ticket
	eventType = "ticket"
	body = /datum/eventRecordBody/TracksPlayer/ticket

	send(
		player_id,
		target,
		reason,
		issuer,
		issuer_job,
		issuer_ckey
	)
		. = ..(args)
