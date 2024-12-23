
/// Record a new fine
/datum/eventRecord/Fine
	eventType = "fine"
	body = /datum/eventRecordBody/TracksPlayer/Fine

	send(
		player_id,
		target,
		reason,
		issuer,
		issuer_job,
		issuer_ckey,
		amount
	)
		. = ..(args)

	buildAndSend(datum/fine/F, mob/living/M)
		src.send(
			M.mind.get_player().id,
			F.target,
			html_decode(F.reason),
			M.real_name,
			M.job,
			M.ckey,
			F.amount
		)
