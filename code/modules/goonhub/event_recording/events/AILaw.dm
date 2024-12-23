
/// Record a new AI law
/datum/eventRecord/AILaw
	eventType = "ai_law"
	body = /datum/eventRecordBody/TracksPlayer/AILaw

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

	buildAndSend(mob/living/silicon/ai/aiPlayer, lawNumber, law)
		// Currently we're only logging AI laws at the end of the round
		// which don't have uploader details attached
		src.send(
			aiPlayer?.mind?.get_player().id,
			aiPlayer.real_name,
			lawNumber,
			html_decode(law)
		)
