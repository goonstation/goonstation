
/// Record an antag item purchase
/datum/eventRecord/AntagItemPurchase
	eventType = "antag_item_purchase"
	body = /datum/eventRecordBody/TracksPlayer/AntagItemPurchase

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

	buildAndSend(mob/living/M, itemIdentifier, cost)
		if (!istype(M))
			return

		var/atom/T = get_turf(M)
		if (!T) T = M

		src.send(
			M.mind.get_player().id,
			M.real_name,
			M.job,
			T.x,
			T.y,
			T.z,
			itemIdentifier ? itemIdentifier : "???",
			cost
		)
