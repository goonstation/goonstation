
/// Record an antag item purchase
/datum/eventRecord/antag_item_purchase
	eventType = "antag_item_purchase"
	body = /datum/eventRecordBody/TracksPlayer/antag_item_purchase

	send(
		player_id,
		mob_name,
		mob_job,
		x,
		y,
		z,
		item,
		cost
	)
		. = ..(args)
