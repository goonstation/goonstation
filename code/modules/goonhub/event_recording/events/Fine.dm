
/// Record a new fine
/datum/eventRecord/Fine
	eventType = "fine"
	body = /datum/eventRecordBody/TracksPlayer/Fine

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
