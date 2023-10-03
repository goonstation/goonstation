
/// Record an antag spawn
/datum/eventRecord/antag
	eventType = "antag"
	body = /datum/eventRecordBody/TracksPlayer/antag

	send(
		player_id,
		mob_name,
		mob_job,
		traitor_type,
		special,
		late_joiner,
		success
	)
		. = ..(args)
