#define POLL_ACTION_CANCEL "cancel"

/client/var/datum/poll_ballot/poll_ballot = new
/client/verb/players_polls()
	set name = "Player Polls"
	set desc = "Cast your vote in a Goonstation poll"
	set category = "Commands"
	poll_ballot.ui_interact(mob)

/datum/poll_ballot
	var/rate_limit_counter = 0
	/// soft cap to start forcing 1 second cooldown
	var/const/rate_limit_soft_cap = 10
	var/filterInactive = TRUE
	/// toggle for whether or not to show the votes on polls
	var/showVotes = FALSE

/datum/poll_ballot/ui_state(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/poll_ballot/ui_status(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/poll_ballot/ui_interact(mob/user, datum/tgui/ui)
	if (!user?.client?.player) return
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "PollBallot")
		ui.open()

/datum/poll_ballot/ui_data(mob/user)
	. = list(
			"isAdmin" = isadmin(user),
			"polls" = poll_manager.poll_data,
			"playerId" = user.client.player.id,
			"filterInactive" = src.filterInactive,
			"showVotes" = src.showVotes
		)

/datum/poll_ballot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	if (!ON_COOLDOWN(ui.user.client.player, "poll_ballot_rate_limit_reset", 1 MINUTE))
		rate_limit_counter = 0
	if ((rate_limit_counter >= rate_limit_soft_cap) && ON_COOLDOWN(ui.user.client.player, "poll_ballot_rate_limit", (1 SECOND + (rate_limit_counter - rate_limit_soft_cap))))
		boutput(ui.user, "<span class='alert'>You're doing that too often!</span>")
		return
	rate_limit_counter++
	switch(action)
		if ("addPoll")
			USR_ADMIN_ONLY
			var/datum/poll_editor_panel/editor = new(ui.user)
			editor.ui_interact(ui.user)
			. = TRUE

		if ("deletePoll")
			USR_ADMIN_ONLY

			try
				var/datum/apiRoute/polls/delete/deletePoll = new
				deletePoll.routeParams = list("[params["pollId"]]")
				apiHandler.queryAPI(deletePoll)
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, null, "Failed to delete a poll: [error.message]")
				return FALSE

			// Remove this poll from our cached data
			for (var/i in 1 to length(poll_manager.poll_data))
				if (poll_manager.poll_data[i]["id"] != params["pollId"])
					continue
				poll_manager.poll_data.Remove(list(poll_manager.poll_data[i]))
				break
			. = TRUE

		if ("editPoll")
			USR_ADMIN_ONLY

			var/question
			var/expires_at
			var/servers
			for (var/list/poll in poll_manager.poll_data)
				if (poll["id"] == text2num(params["pollId"]))
					question = poll["question"]
					expires_at = poll["expires_at"]
					servers = poll["servers"]
					break

			question = tgui_input_text(ui.user, "Enter the poll question", "Edit Poll", question, MAX_MESSAGE_LEN)
			question = copytext(html_encode(question), 1, MAX_MESSAGE_LEN)
			if (!question) return

			try
				var/datum/apiRoute/polls/edit/editPoll = new
				editPoll.routeParams = list("[params["pollId"]]")
				editPoll.buildBody(question, expires_at, servers)
				apiHandler.queryAPI(editPoll)
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, null, "Failed to edit a poll: [error.message]")
				return FALSE

			poll_manager.sync_single_poll(params["pollId"])
			. = TRUE

		if ("editExpiration")
			if (!ui.user.client.holder) return FALSE
			USR_ADMIN_ONLY

			var/question
			var/expires_at
			var/servers
			for (var/list/poll in poll_manager.poll_data)
				if (poll["id"] == text2num(params["pollId"]))
					question = poll["question"]
					expires_at = poll["expires_at"]
					servers = poll["servers"]
					break

			expires_at = src.pick_expiration_date(ui.user)
			if (expires_at == POLL_ACTION_CANCEL) return // user canceled

			try
				var/datum/apiRoute/polls/edit/editPoll = new
				editPoll.routeParams = list("[params["pollId"]]")
				editPoll.buildBody(question, expires_at, servers)
				apiHandler.queryAPI(editPoll)
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, null, "Failed to edit a poll: [error.message]")
				return FALSE

			poll_manager.sync_single_poll(params["pollId"])
			. = TRUE

		if ("editServers")
			if (!ui.user.client.holder) return FALSE
			USR_ADMIN_ONLY

			var/question
			var/expires_at
			var/servers
			for (var/list/poll in poll_manager.poll_data)
				if (poll["id"] == text2num(params["pollId"]))
					question = poll["question"]
					expires_at = poll["expires_at"]
					servers = poll["servers"]
					break

			servers = src.pick_servers(ui.user)
			if (servers == POLL_ACTION_CANCEL) return // user canceled

			try
				var/datum/apiRoute/polls/edit/editPoll = new
				editPoll.routeParams = list("[params["pollId"]]")
				editPoll.buildBody(question, expires_at, servers)
				apiHandler.queryAPI(editPoll)
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, null, "Failed to edit a poll: [error.message]")
				return FALSE

			poll_manager.sync_single_poll(params["pollId"])
			. = TRUE

		if ("addOption")
			USR_ADMIN_ONLY

			var/option = tgui_input_text(ui.user, "Enter a poll option", "Add Option", null, MAX_MESSAGE_LEN)
			option = copytext(html_encode(option), 1, MAX_MESSAGE_LEN)
			if (!option) return

			try
				var/datum/apiRoute/polls/options/add/addPollOption = new
				addPollOption.routeParams = list("[params["pollId"]]")
				addPollOption.buildBody(option)
				apiHandler.queryAPI(addPollOption)
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, null, "Failed to add an option to a poll: [error.message]")
				return FALSE

			poll_manager.sync_single_poll(params["pollId"])
			. = TRUE

		if ("deleteOption")
			USR_ADMIN_ONLY

			try
				var/datum/apiRoute/polls/options/delete/deletePollOption = new
				deletePollOption.routeParams = list("[params["optionId"]]")
				apiHandler.queryAPI(deletePollOption)
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, null, "Failed to delete an option from a poll: [error.message]")
				return FALSE

			poll_manager.sync_single_poll(params["pollId"])
			. = TRUE

		if ("editOption")
			USR_ADMIN_ONLY

			var/option
			for (var/list/poll as anything in poll_manager.poll_data)
				if (poll["id"] == text2num(params["pollId"]))
					for (var/list/pollOption in poll["options"])
						if (pollOption["id"] == text2num(params["optionId"]))
							option = pollOption["option"]
							break

			option = tgui_input_text(ui.user, "Enter a poll option", "Edit Option", option, MAX_MESSAGE_LEN)
			option = copytext(html_encode(option), 1, MAX_MESSAGE_LEN)
			if (!option) return

			try
				var/datum/apiRoute/polls/options/edit/editPollOption = new
				editPollOption.routeParams = list("[params["optionId"]]")
				editPollOption.buildBody(option, null)
				apiHandler.queryAPI(editPollOption)
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, null, "Failed to edit an option on a poll: [error.message]")
				return FALSE

			poll_manager.sync_single_poll(params["pollId"])
			. = TRUE

		if ("vote")
			var/player_id = ui.user.client.player.id
			if (!player_id) return

			// determine if we are treating this as a pick or unpick
			var/voted_for_option = FALSE
			for (var/list/poll in poll_manager.poll_data)
				if (poll["id"] != text2num(params["pollId"]))
					continue
				for (var/list/option in poll["options"])
					if (option["id"] != text2num(params["optionId"]))
						continue
					if (ui.user.client.player.id in option["answers_player_ids"])
						voted_for_option = TRUE
					break
				break

			try
				if (voted_for_option)
					var/datum/apiRoute/polls/options/unpick/unPickOption = new
					unPickOption.routeParams = list("[params["optionId"]]")
					unPickOption.buildBody(player_id)
					apiHandler.queryAPI(unPickOption)
				else
					var/datum/apiRoute/polls/options/pick/pickOption = new
					pickOption.routeParams = list("[params["optionId"]]")
					pickOption.buildBody(player_id)
					apiHandler.queryAPI(pickOption)
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, null, "Failed to pick/unpick an option on a poll: [error.message]")
				return FALSE

			poll_manager.sync_single_poll(params["pollId"])
			. = TRUE

		if("toggle-filterInactive")
			filterInactive = !filterInactive
			. = TRUE

		if ("toggle-showVotes")
			showVotes = !showVotes
			. = TRUE


/// prompts users to select a date in the future, returns an iso8601 string or null
/datum/poll_ballot/proc/pick_expiration_date(user)
	. = POLL_ACTION_CANCEL
	var/expiration_choice = tgui_input_list(user, "Set an expiration date", "Add Poll",
		list(
			"None",
			"Custom Minutes",
			"Custom Hours",
			"Custom Days",
			"Custom ISO8601 Timestamp",
			))
	switch (expiration_choice)
		if ("None")
			. = null
		if ("Custom Minutes")
			var/input = tgui_input_number(user, "How many minutes?", "Add Poll", 1, 10000, 0)
			. = toIso8601(addTime(subtractTime(world.realtime, hours = world.timezone), minutes = input))
		if ("Custom Hours")
			var/input = tgui_input_number(user, "How many hours?", "Add Poll", 1, 10000, 0)
			. = toIso8601(addTime(subtractTime(world.realtime, hours = world.timezone), hours = input))
		if ("Custom Days")
			var/input = tgui_input_number(user, "How many days?", "Add Poll", 1, 10000, 0)
			. = toIso8601(addTime(subtractTime(world.realtime, hours = world.timezone), days = input))
		if ("Custom ISO8601 Timestamp")
			var/input = tgui_input_text(user, "Please provide a valid ISO8601 formatted timestamp?", "Add Poll", toIso8601(subtractTime(world.realtime, hours = world.timezone)))
			if (validateIso8601(input))
				. = input
			else
				tgui_alert(user, "Invalid timestamp provided, poll defaulting to no expiration", "Error")

/// prompts users to select which servers to target for polling
/datum/poll_ballot/proc/pick_servers(user)
	var/servers = tgui_alert(user, "Poll type?", "Targeted Servers", list("Local", "Global", "RP Only"))
	switch(servers)
		if ("Local")
			. = list(config.server_id)
		if ("Global")
			. = list(poll_manager.global_server_id)
		if ("RP Only")
			. = list(poll_manager.rp_only_server_id)
		else
			. = POLL_ACTION_CANCEL

#undef POLL_ACTION_CANCEL
