
/// Record a bee spawn
/datum/eventRecord/BeeSpawn
	eventType = "bee_spawn"
	body = /datum/eventRecordBody/BeeSpawn

	send(
		name
	)
		. = ..(args)
