
/// GET /random-entries
/// Get a list of random entries by type
/datum/apiRoute/randomEntries
	method = RUSTG_HTTP_METHOD_GET
	path = "/random-entries"
	queryParams = list("type", "count")	// not sure if i should put 0 or "count" here.
	correct_response = list(/datum/apiModel/Tracked/EventTicketResource,
							/datum/apiModel/Tracked/EventFineResource,
							/datum/apiModel/Tracked/EventAiLawResource,
							/datum/apiModel/Tracked/EventStationNameResource)	// this may or may not work
