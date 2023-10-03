
/// Record a new AI law
/datum/eventRecord/ai_law
	eventType = "ai_law"
	body = /datum/eventRecordBody/TracksPlayer/ai_law

	send(
		player_id,
		ai_name,
		law_number,
		law_text,
		uploader_name,
		uploader_job,
		uploader_ckey
	)
		. = ..(args)
