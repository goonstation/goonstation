
/// Record a player death
/datum/eventRecord/death
	eventType = "death"
	body = /datum/eventRecordBody/TracksPlayer/death

	setBody(
		player_id,
		mob_name,
		mob_job,
		x,
		y,
		z,
		bruteloss,
		fireloss,
		toxloss,
		oxyloss,
		gibbed,
		last_words
	)
		. = ..(args)
