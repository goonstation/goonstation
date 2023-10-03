
/// Record a new station name
/datum/eventRecord/station_name
	eventType = "station_name"
	body = /datum/eventRecordBody/station_name

	send(
		name
	)
		. = ..(args)
