
/// Record a player death
/datum/eventRecord/death
	eventType = "death"
	body = /datum/eventRecordBody/TracksPlayer/death

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
			0, // TODO: get player ID (when API system exists to populate that)
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
			M.last_words
		)
