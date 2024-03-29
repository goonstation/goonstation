
/// Record a log message
/datum/eventRecord/Log
	eventType = "log"
	body = /datum/eventRecordBody/Log

	send(
		type,
		source,
		message
	)
		. = ..(args)
