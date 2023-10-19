
/// Record a new gauntlet high score
/datum/eventRecord/GauntletHighScore
	eventType = "gauntlet_high_score"
	body = /datum/eventRecordBody/GauntletHighScore

	send(
		names,
		score,
		highest_wave
	)
		. = ..(args)
