
/// Record a new fine
/datum/eventRecord/fine
	eventType = "fine"
	body = /datum/eventRecordBody/TracksPlayer/fine

	send(
		player_id,
		target,
		reason,
		issuer,
		issuer_job,
		issuer_ckey,
		amount
	)
		. = ..(args)
