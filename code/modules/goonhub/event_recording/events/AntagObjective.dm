
/// Record an antag objective addition
/datum/eventRecord/antag_objective
	eventType = "antag_objective"
	body = /datum/eventRecordBody/TracksPlayer/antag_objective

	send(
		player_id,
		objective,
		success
	)
		. = ..(args)
