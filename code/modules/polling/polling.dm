/client/var/datum/voting_ballot/voting_ballot = new

/datum/voting_ballot
	var/list/choices

/datum/voting_ballot/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/voting_ballot/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/voting_ballot/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "VotingBallot")
	ui.open()

/datum/voting_ballot/ui_data(mob/user)

	. = list(
			"isAdmin" = isadmin(user),
			"polls" = list(
				list(
				"id" = "123465",
				"question" = "Which map?",
				"totalVotes" = 10,
				"options" = list(
					list(
					"name" = "Cogmap 1",
					"voteCount" = 3,
					"voted" = 0
					),
					list(
					"name" = "1 pamgoC",
					"voteCount" = 5,
					"voted" = 1
					),
					list(
					"name" = "Atlas",
					"voteCount" = 2,
					"voted" = 0
					)
				)
				),
				list(
				"id" = "123",
				"question" = "Do I gib everyone?",
				"totalVotes" = 20,
				"options" = list(
					list(
					"name" = "yes",
					"voteCount" = 10,
					"voted" = 1
					),
					list(
					"name" = "no",
					"voteCount" = 10,
					"voted" = 0
					)
				)
				)
			)


		)

/datum/voting_ballot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
	 if("temp") return
