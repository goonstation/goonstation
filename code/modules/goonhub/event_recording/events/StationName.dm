
/// Record a new station name
/datum/eventRecord/StationName
	eventType = "station_name"
	body = /datum/eventRecordBody/StationName

	send(
		name
	)
		. = ..(args)
