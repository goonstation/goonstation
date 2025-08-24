
/// Record a player death
/datum/eventRecord/Death
	eventType = "death"
	body = /datum/eventRecordBody/TracksPlayer/Death

	send(
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

	buildAndSend(mob/living/M, gibbed)
		var/atom/T = get_turf(M)
		if (!T) T = M

		src.send(
			M.mind.get_player().id,
			M.real_name,
			M.job,
			T.x,
			T.y,
			T.z,
			M.get_brute_damage(),
			M.get_burn_damage(),
			M.get_toxin_damage(),
			M.get_oxygen_deprivation(),
			gibbed ? TRUE : FALSE,
			strip_html_tags(html_decode(M.last_words)) //decode, then strip the tags out, otherwise they get rendered as text on the website x.x
		)
