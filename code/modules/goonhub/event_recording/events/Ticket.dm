
/// Record a new ticket
/datum/eventRecord/Ticket
	eventType = "ticket"
	body = /datum/eventRecordBody/TracksPlayer/Ticket

	send(
		player_id,
		target,
		reason,
		issuer,
		issuer_job,
		issuer_ckey
	)
		. = ..(args)

	buildAndSend(datum/ticket/T, mob/living/M)
		src.send(
			M.mind.get_player().id,
			T.target,
			html_decode(T.reason),
			M.real_name,
			M.job,
			M.ckey
		)
