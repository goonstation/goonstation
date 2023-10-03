
/// Record a new gauntlet high score
/datum/eventRecord/gauntlet_high_score
	eventType = "gauntlet_high_score"
	body = /datum/eventRecordBody/gauntlet_high_score

	send(
		names,
		score,
		highest_wave
	)
		. = ..(args)
