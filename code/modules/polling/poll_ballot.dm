/client/var/datum/poll_ballot/poll_ballot = new
/client/verb/players_polls()
	set name = "Player Polls"
	set desc = "Cast your vote in a Goonstation poll"
	set category = "Commands"
	poll_ballot.ui_interact(mob)

/datum/poll_ballot

/datum/poll_ballot/ui_state(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/poll_ballot/ui_status(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/poll_ballot/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "PollBallot")
	ui.open()

/datum/poll_ballot/ui_data(mob/user)
	. = list(
			"isAdmin" = isadmin(user),
			"polls" = poll_manager.poll_data?["data"],
			"playerId" = user.client.player.fetch_player_id(user.ckey)
		)

/datum/poll_ballot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("addPoll")
			USR_ADMIN_ONLY

			var/question = tgui_input_text(ui.user, "Enter the poll question", "Add Poll", null, MAX_MESSAGE_LEN)
			question = copytext(html_encode(question), 1, MAX_MESSAGE_LEN)
			if (!question) return

			var/list/options = list()
			var/option = TRUE
			while(option)
				option = tgui_input_text(ui.user, "Enter a poll option. Press Cancel to stop adding new options", "Add Poll", null, MAX_MESSAGE_LEN)
				option = copytext(html_encode(option), 1, MAX_MESSAGE_LEN)
				if (option)
					options += option
			if (!options) return

			var/multiple_choice = tgui_alert(ui.user, "Multiple choice?", "Add Poll", list("Yes", "No"))
			if (multiple_choice == "Yes")
				multiple_choice = TRUE
			else
				multiple_choice = FALSE

			var/datum/http_request/request = new
			var/list/headers = list(
				"Accept" = "application/json",
				"Authorization" = config.goonhub_api_token,
				"Content-Type" = "application/json"
			)
			var/list/body = list(
				"game_admin_ckey" = ui.user.ckey,
				"question" = question,
				"multiple_choice" = multiple_choice,
				"expires_at" = null,
				"options" = options
			)
			body = json_encode(body)
			request.prepare(RUSTG_HTTP_METHOD_POST, "[config.goonhub_api_endpoint]/api/polls", body, headers)
			request.begin_async()
			UNTIL(request.is_complete())
			var/datum/http_response/response = request.into_response()
			if (rustg_json_is_valid(response.body))
				var/list/L = poll_manager.poll_data?["data"]
				L.Insert(1, list(json_decode(response.body)?["data"]))
				poll_manager.poll_data?["data"] = L
			. = TRUE

		if ("deletePoll")
			USR_ADMIN_ONLY

			var/datum/http_request/request = new
			var/list/headers = list(
				"Accept" = "application/json",
				"Authorization" = config.goonhub_api_token,
			)
			request.prepare(RUSTG_HTTP_METHOD_DELETE, "[config.goonhub_api_endpoint]/api/polls/[params["pollId"]]", null, headers)
			request.begin_async()
			UNTIL(request.is_complete())
			poll_manager.sync_single_poll(params["pollId"])
			. = TRUE

		if ("editPoll")
			USR_ADMIN_ONLY

			var/question
			for (var/list/poll as anything in poll_manager.poll_data?["data"])
				if (poll["id"] == params["pollId"])
					question = poll["question"]
					break

			question = tgui_input_text(ui.user, "Enter the poll question", "Edit Poll", question, MAX_MESSAGE_LEN)
			question = copytext(html_encode(question), 1, MAX_MESSAGE_LEN)
			if (!question) return

			var/datum/http_request/request = new
			var/list/headers = list(
				"Accept" = "application/json",
				"Authorization" = config.goonhub_api_token,
				"Content-Type" = "application/json"
			)
			var/list/body = list(
				"question" = question,
				"expires_at" = null
			)
			body = json_encode(body)
			request.prepare(RUSTG_HTTP_METHOD_PUT, "[config.goonhub_api_endpoint]/api/polls/[params["pollId"]]", body, headers)
			request.begin_async()
			UNTIL(request.is_complete())
			poll_manager.sync_single_poll(params["pollId"])
			. = TRUE

		if ("addOption")
			USR_ADMIN_ONLY

			var/option = tgui_input_text(ui.user, "Enter a poll option", "Add Option", null, MAX_MESSAGE_LEN)
			option = copytext(html_encode(option), 1, MAX_MESSAGE_LEN)
			if (!option) return

			var/datum/http_request/request = new
			var/list/headers = list(
				"Accept" = "application/json",
				"Authorization" = config.goonhub_api_token,
				"Content-Type" = "application/json"
			)
			var/list/body = list(
				"option" = option
			)
			body = json_encode(body)
			request.prepare(RUSTG_HTTP_METHOD_POST, "[config.goonhub_api_endpoint]/api/polls/option/[params["pollId"]]", body, headers)
			request.begin_async()
			UNTIL(request.is_complete())
			poll_manager.sync_single_poll(params["pollId"])
			. = TRUE

		if ("deleteOption")
			USR_ADMIN_ONLY

			var/datum/http_request/request = new
			var/list/headers = list(
				"Accept" = "application/json",
				"Authorization" = config.goonhub_api_token,
			)
			request.prepare(RUSTG_HTTP_METHOD_DELETE, "[config.goonhub_api_endpoint]/api/polls/option/[params["optionId"]]", null, headers)
			request.begin_async()
			UNTIL(request.is_complete())
			poll_manager.sync_single_poll(params["pollId"])
			. = TRUE

		if ("editOption")
			USR_ADMIN_ONLY

			var/option
			for (var/list/poll as anything in poll_manager.poll_data?["data"]["options"])
				if (poll["id"] == params["optionId"])
					option = poll["option"]
					break

			option = tgui_input_text(ui.user, "Enter a poll option", "Edit Option", option, MAX_MESSAGE_LEN)
			option = copytext(html_encode(option), 1, MAX_MESSAGE_LEN)
			if (!option) return

			var/datum/http_request/request = new
			var/list/headers = list(
				"Accept" = "application/json",
				"Authorization" = config.goonhub_api_token,
				"Content-Type" = "application/json"
			)
			var/list/body = list(
				"option" = option,
				"position" = null
			)
			body = json_encode(body)
			request.prepare(RUSTG_HTTP_METHOD_PUT, "[config.goonhub_api_endpoint]/api/polls/option/[params["optionId"]]", body, headers)
			request.begin_async()
			UNTIL(request.is_complete())
			poll_manager.sync_single_poll(params["pollId"])
			. = TRUE

		if ("vote")
			var/player_id = ui.user.client.player.fetch_player_id(ui.user.ckey)
			if (!player_id) return

			// determine if we are treating this as a pick or unpick
			var/voted_for_option = FALSE
			for (var/list/L as anything in poll_manager.poll_data?["data"])
				if (L["id"] != params["pollId"])
					continue
				for (var/list/option as anything in L["options"])
					if (option["id"] != params["optionId"])
						continue
					if (player_id in option["answers_player_ids"])
						voted_for_option = TRUE
					break
				break

			var/datum/http_request/request = new
			var/list/headers = list(
				"Accept" = "application/json",
				"Authorization" = config.goonhub_api_token,
				"Content-Type" = "application/json"
			)
			var/list/body = list(
				"player_id" = player_id,
			)
			body = json_encode(body)
			request.prepare(RUSTG_HTTP_METHOD_POST, "[config.goonhub_api_endpoint]/api/polls/option/[voted_for_option ? "unpick" : "pick"]/[params["optionId"]]", body, headers)
			request.begin_async()
			UNTIL(request.is_complete())
			poll_manager.sync_single_poll(params["pollId"])
			. = TRUE

