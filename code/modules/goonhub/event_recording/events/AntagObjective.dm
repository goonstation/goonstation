
/// Record an antag objective addition
/datum/eventRecord/AntagObjective
	eventType = "antag_objective"
	body = /datum/eventRecordBody/TracksPlayer/AntagObjective

	send(
		player_id,
		objective,
		success
	)
		. = ..(args)

	buildAndSend(datum/antagonist/antagonist_role, datum/objective/objective)
		var/datum/mind/M = antagonist_role.owner

		src.send(
			M.get_player().id,
			objective.explanation_text,
			objective.check_completion() ? TRUE : FALSE
		)
