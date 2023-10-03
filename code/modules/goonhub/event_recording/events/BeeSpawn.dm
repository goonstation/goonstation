
/// Record a bee spawn
/datum/eventRecord/bee_spawn
	eventType = "bee_spawn"
	body = /datum/eventRecordBody/bee_spawn

	send(
		name
	)
		. = ..(args)
